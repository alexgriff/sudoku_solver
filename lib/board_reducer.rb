class Board::Reducer
  attr_reader :board_state
  def initialize(board_state)
    @board_state = board_state
  end

  def touched_reducer(state, action)
    case action.type
      when Action::INIT, Action::NEW_PASS
        false
      when Action::FILL_CELL, Action::UPDATE_CELL
        cell = board_state.get_cell(action.cell_id)
        new_values = action.respond_to?(:values) ? action.values : [action.value]
        # this breaks encapsulation since the touced reducer has to reach into
        # the cells part of the state, could pass thru state like {touched:, cells:}... hmmm....
        if cell.empty? && (board_state.instance_variable_get(:@cells)[cell.id] != new_values)
          true
        else
          state
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
      new_board_sync_cells_reducer(state, action)
    when Action::FILL_CELL, Action::UPDATE_CELL
      update_cell_reducer(state, action)
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

  private

  def new_board_sync_cells_reducer(state, action)
    empty_cell_id_to_seen_values_map = action.initial_data.each_with_object({}).with_index do |(val, res), i|
      if val == Cell::EMPTY
        res[i] = action.seen_cell_ids_map[i].map { |id| action.initial_data[id] }.reject { |v| v == Cell::EMPTY }
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
  end

  def update_cell_reducer(state, action)
    cell = board_state.get_cell(action.cell_id)
    new_values = action.respond_to?(:values) ? action.values : [action.value]
    if cell.empty? && new_values != state[action.cell_id]
      state.map.with_index do |v, i|
        if i == action.cell_id
          action.respond_to?(:values) ? action.values : [action.value]
        else
          v
        end
      end
    else
      state
    end
  end
end
