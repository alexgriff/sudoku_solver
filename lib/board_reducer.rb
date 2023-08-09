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
    when Action::INIT_FILL_CELL, Action::FILL_CELL, Action::INIT_UPDATE_CELL, Action::UPDATE_CELL
      if board.get_cell(action.cell_id).empty?
        state_copy = state.dup
        new_values = action.respond_to?(:values) ? action.values : [action.value]
        state_copy[action.cell_id] = new_values
        state_copy
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
    when Action::INIT_FILL_CELL, Action::FILL_CELL
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
