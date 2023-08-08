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
        cells2: cells2_reducer(board.state[:cells2], action),
        solved: solved_reducer(board.state[:solved], action)
      }
    )

    # TODO: remove this!
    c_state = board.state[:cells].map { |c| c.filled? ? [c.value] : c.candidates }
    c_state2 = board.state[:cells2]

    c_state.each.with_index do |cr, idx|
      # if cr != c_state2[idx]
      #   raise 'oh no!'
      # end
    end
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
    when Action::NEW_PASS
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

  def cells2_reducer(state, action)
    case action.type
    when Action::INIT
      (0..(Board::NUM_CELLS - 1)).to_a.map { |i| Cell::ALL_CANDIDATES.dup }
    when Action::FILL_CELL
      fill_cell2(state, action)
    when Action::UPDATE_CANDIDATES
      update_candidates2(state, action)
    else
      state
    end
  end

  def solved_reducer(state, action)
    case action.type
    when Action::INIT
      {}
    when Action::FILL_CELL
      copied_state = state.clone
      copied_state[action.cell_id] = action.value
      copied_state
    else
      state
    end
  end

  private

  def fill_cell(state, action)
    # debugger if action.cell_id == 69 && action.value == 9 && action.strategy == Strategy::NakedPair.name
    fillable_cell = state[action.cell_id]
    row = Row.for_cell(board, fillable_cell)
    col = Column.for_cell(board, fillable_cell)
    box = Box.for_cell(board, fillable_cell)

    cell_ids_to_be_updated = [row, col, box].map do |house, res|
      house.other_cells_with_candidates([fillable_cell.id], [action.value])
    end.flatten.map(&:id)

    # debugger if action.cell_id == 69 && action.value == 9 && action.strategy == Strategy::NakedPair.name
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

  def fill_cell2(state, action)
    fillable_cell = Cell.from_state(id: action.cell_id, state: state[action.cell_id])
    row = Row.for_cell(board, fillable_cell)
    col = Column.for_cell(board, fillable_cell)
    box = Box.for_cell(board, fillable_cell)

    # cell_ids_to_be_updated = [row, col, box].map do |house, res|
    #   house.other_cells_ids_with_candidates([fillable_cell.id], [action.value])
    # end.flatten
    
    # fix this
    # this should return
    # [66, 78, 78]
    # getting [66, 69, 69, 69]
    cell_ids_to_be_updated = [row, col, box].map do |house, res| house.other_cells_ids_with_candidates([fillable_cell.id], [action.value]) end.flatten

    state.map.with_index do |state_cell, i|
      if i == action.cell_id
        [action.value]
      elsif (cell_ids_to_be_updated).include?(i)
        state_cell - [action.value]
      else
        state_cell
      end
    end
  end

  def update_candidates2(state, action)
    state_copy = state.dup
    state_copy[action.cell_id] = action.new_candidates
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
