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
        if action.possible_values != board.state[:cells][action.cell_id]
          true
        else
          false
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
    when Action::UPDATE_CELL
      update_cell(state, action)
    else
      state
    end
  end

  def solved_reducer(state, action)
    case action.type
    when Action::INIT
      {}
    when Action::UPDATE_CELL
      if action.possible_values.length == 1
        copied_state = state.clone
        copied_state[action.cell_id] = action.possible_values.first
        copied_state
      else
        state
      end
    else
      state
    end
  end

  private

  def update_cell(state, action)
    cell = board.get_cell(action.cell_id)
    seen_cell_ids_needing_update = []

    if action.possible_values.length == 1
      seen_cell_ids_needing_update = board.all_seen_empty_cells_for(cell).select do |seen_cell|
        seen_cell.candidates.include?(action.possible_values.first)
      end.map(&:id)
    end
    # debugger if action.cell_id == 23 || seen_cell_ids_needing_update.include?(23)

    x = state.map.with_index do |values, i|
      if i == action.cell_id
        action.possible_values
      elsif (seen_cell_ids_needing_update).include?(i)
        foo = values - action.possible_values
        # debugger if foo.length == 0
        foo
      else
        values
      end
    end
    # debugger
    x
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
