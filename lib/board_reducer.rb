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
      when Action::INIT
        false
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
      when Action::INIT
        0
      when  Action::NEW_PASS
        state + 1
      else
        state
    end
  end

  def cells_reducer(state, action)
    case action.type
      when Action::INIT
        (0..(Board::NUM_CELLS - 1)).to_a.map { |i| Cell.new(id: i) }
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
    fillable_cell = state[action.cell_id]
    row = Row.for_cell(board, fillable_cell)
    col = Column.for_cell(board, fillable_cell)
    box = Box.for_cell(board, fillable_cell)

    cell_ids_to_be_updated = [row, col, box].map do |house, res|
      house.other_cells_with_candidates([fillable_cell.id], [action.value])
    end.flatten.map(&:id)

    state.map do |cell|
      if cell == fillable_cell
        Cell.new(
          id: action.cell_id,
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
    cell = state[action.cell_id]
    
    state_copy[action.cell_id] = Cell.new(
        id: cell.id,
        value: cell.value,
        candidates: action.new_candidates
    )
    state_copy
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
      select(**kwargs).first
    end

    def select(**kwargs)
      @history.select do |action|
        kwargs.all? do |key, val|
          action.respond_to?(key) ? action.send(key) == val : false
        end
      end
    end
  end
end
