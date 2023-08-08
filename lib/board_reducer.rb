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
        cells: cells_reducer(board.state[:cells], action)
      }
    )
  end

  def touched_reducer(state, action)
    case action.type
      when Action::INIT, Action::INIT_CELL, Action::NEW_PASS
        false
      when Action::UPDATE_CELL
        cell = board.get_cell(action.cell_id)
        if (board.state[:cells][cell.id] == action.possible_values) || cell.filled?
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
    when Action::INIT_CELL, Action::UPDATE_CELL
      state_copy = state.dup
      cell = board.get_cell(action.cell_id)
      unless cell.filled?
        state_copy[action.cell_id] = action.possible_values
      end
      state_copy
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

    def find(**kwargs)
      where(**kwargs).first
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
