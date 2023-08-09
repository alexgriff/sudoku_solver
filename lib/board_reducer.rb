class Board::Reducer
  attr_reader :board, :history
  
  def initialize(board)
    @board = board
    @history = History.new
  end

  def dispatch(action)
    history << action
    board.set_state(
      {
        touched: touched_reducer(board.state[:touched], action),
        passes: passes_reducer(board.state[:passes], action),
        cells: cells_reducer(board.state[:cells], action),
        solved: solved_reducer(board.state[:solved], action)
      }
    )
  end

  def touched_reducer(state, action)
    case action.type
      when Action::INIT, Action::NEW_PASS
        false
      when Action::UPDATE_CELL
        cell = board.get_cell(action.cell_id)
        if (board.state[:cells][cell.id] == action.values) || cell.filled?
          state
        else
          true
        end
      else
        state
    end
  end

  def passes_reducer(state, action)
    case action.type
    when Action::INIT
      0
    when Action::NEW_PASS
      state + 1
    else
      state
    end
  end
  
  def cells_reducer(state, action)
    case action.type
    when Action::INIT
      (0..(Board::NUM_CELLS - 1)).to_a.map { |i| Cell::ALL_CANDIDATES.dup }
    when Action::NEW_BOARD_SYNC
      empty_cell_id_to_seen_values_map = action.initial_data.each_with_object({}).with_index do |(val, res), i|
        if val == Cell::EMPTY
          res[i] = board.all_seen_cell_ids_for(i).map { |id| action.initial_data[id] }.reject { |v| v == Cell::EMPTY }
        end
        res
      end

      state.map.with_index do |cell, i|
        filled_values_cell_can_see = empty_cell_id_to_seen_values_map[i]
        if filled_values_cell_can_see
          cell - filled_values_cell_can_see
        else
          [action.initial_data[i]]
        end
      end
    when Action::FILL_CELL, Action::UPDATE_CELL
      if board.get_cell(action.cell_id).empty?
        new_values = action.respond_to?(:values) ? action.values : [action.value]
        if state[action.cell_id] != new_values
          state_copy = state.dup
          state_copy[action.cell_id] = new_values
          state_copy
        else
          state
        end
      else
        state
      end
    else
      state
    end
  end

  def solved_reducer(state, action)
    case action.type
    when Action::INIT
      {}
    when Action::NEW_BOARD_SYNC
      action.initial_data.each_with_object({}).with_index do |(v, res), i|
        if v != Cell::EMPTY
          res[i] = v
        end
        res
      end
    when Action::FILL_CELL
      state.merge({action.cell_id => action.value})
    else
      state
    end
  end

  class History
    def initialize()
      @history = []
    end

    def <<(next_action)
      @history << next_action
    end

    def [](index)
      @history[index]
    end

    def all
      @history.dup
    end

    def last(n=1)
      @history.last(n)
    end

    def length
      @history.length
    end

    def find(**kwargs)
      where(**kwargs).first
    end

    def after_id(action_id)
      start_index = @history.index { |action| action.id == action_id}
      @history[start_index..-1]
    end

    def where(**kwargs)
      @history.select do |action|
        kwargs.all? do |key, val|
          if val == nil
            !action.respond_to?(key) || !action.send(key)
          else
            action.respond_to?(key) ? action.send(key) == val : false
          end
        end
      end
    end
  end
end
