class Board::Reducer
  def self.touched_reducer(state, action)
    case action.type
      when Action::INIT, Action::NEW_BOARD_SYNC, Action::NEW_PASS
        false
      when Action::UPDATE_CELL
        if state[:cells][action.cell_id].length > 1 && (state[:cells][action.cell_id] != action.values)
          true
        else
          state[:touched]
        end
      else
        state[:touched]
    end
  end

  def self.passes_reducer(state, action)
    case action.type
    when Action::INIT
      0
    when Action::NEW_PASS
      state + 1
    else
      state
    end
  end
  
  def self.cells_reducer(state, action)
    case action.type
    when Action::INIT
      (0..(Board::NUM_CELLS - 1)).to_a.map { |i| Cell::ALL_CANDIDATES.dup }

    when Action::NEW_BOARD_SYNC
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

    when Action::UPDATE_CELL
      if state[action.cell_id].length > 1
        state.map.with_index do |v, i|
          if i == action.cell_id
            action.values
          else
            v
          end
        end
      else
        state
      end

    else
      state
    end
  end

  def self.solved_reducer(state, action)
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
    when Action::UPDATE_CELL
      if action.solves
        state.merge({action.cell_id => action.values.first})
      else
        state
      end
    else
      state
    end
  end
end
