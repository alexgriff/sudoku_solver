class Board::Reducer
  attr_reader :board, :history
  
  def initialize(board)
    @board = board
    @history = []
  end

  def dispatch(action)
    history << action
    board.state = {
      touched: touched_reducer(board.state[:touched], action),
      passes: passes_reducer(board.state[:passes], action),
      cells: cells_reducer(board.state[:cells], action)
    }
  end

  def touched_reducer(state, action)
    case action.type
      when Action::FILL_CELL
        true
      when Action::UPDATE_CANDIDATES
        true
      when Action::NEW_PASS
        false
      else
        state
    end
  end

  def passes_reducer(state, action)
    case action.type
      when  Action::NEW_PASS
        state + 1
      else
        state
    end
  end

  def cells_reducer(state, action)
    case action.type
      when Action::FILL_CELL
        fill_cell(state, action)
      when Action::UPDATE_CANDIDATES
        update_candidates(state, action)
      else
        state
    end
  end

  private

  def fill_cell(state, action)
    fillable_cell = state[action.id]
    row = Row.for_cell(board, fillable_cell)
    col = Column.for_cell(board, fillable_cell)
    box = Box.for_cell(board, fillable_cell)

    cell_ids_to_be_updated = [row, col, box].map do |house, res|
      house.other_cells_with_candidates([fillable_cell.id], [action.value])
    end.flatten.map(&:id)

    state.map do |cell|
      if cell == fillable_cell
        Cell.new(
          id: action.id,
          value: action.value,
          candidates: []
        )
      elsif (cell_ids_to_be_updated).include?(cell.id)
        Cell.new(
          id: cell.id,
          value: cell.value,
          candidates: cell.candidates - [action.value]
        )
      else
        cell
      end
    end
  end

  def update_candidates(state, action)
    state_copy = state.dup
    cell = state[action.id]
    
    state_copy[action.id] = Cell.new(
        id: cell.id,
        value: cell.value,
        candidates: action.new_candidates
    )
    state_copy
  end
end
