class Board::State
  attr_reader :board

  def initialize(board)
    @touched = nil
    @passes = nil
    @solved = nil
    @cells = nil

    @reducer = Board::Reducer.new(self)
    @board = board
    dispatch(Action.new(type: Action::INIT))
  end

  def get_cell(id)
    Cell.new(
      id: id,
      value: @solved[id] || Cell::EMPTY,
      candidates: @cells[id]
    )
  end

  def is_solved?
    @solved.keys.length == Board::NUM_CELLS
  end

  def has_been_touched?
    @touched
  end

  def current_pass
    @passes
  end

  def set_touched(touched_state)
    @touched = touched_state
  end
  
  def set_passes(passes_state)
    @passes = passes_state
  end
  
  def set_solved(solved_state)
    @solved = solved_state
  end
  
  def set_cells(cells_state)
    @cells = cells_state
  end

  def dispatch(action)
    board.history << action
    set_touched(reducer.touched_reducer(@touched, action))
    set_passes(reducer.passes_reducer(@passes, action))
    set_solved(reducer.solved_reducer(@solved, action))
    set_cells(reducer.cells_reducer(@cells, action))
  end

  def register_next_pass
    dispatch(Action.new(type: Action::NEW_PASS))
  end

  def register_done
    dispatch(Action.new(type: Action::DONE, status: is_solved?))
  end

  def register_starting_state(initial_data)
    dispatch(
      Action.new(
        type: Action::NEW_BOARD_SYNC,
        initial_data: initial_data
      )
    )
  end

  def register_change(cell_id, candidates, action_opts={})
    cell = get_cell(cell_id)
    solving = cell.empty? && candidates.length == 1

    if solving
      dispatch(
        Action.new(
          type: Action::FILL_CELL,
          cell_id: cell_id,
          value: candidates.first,
          **action_opts
        )
      )
      board.all_seen_empty_cell_ids_with_candidates_for(cell_id, candidates).each do |seen_cell_id|
        seen_cell = get_cell(seen_cell_id)
        # Because the board state can change from a previous iteration of this loop, all cells that were empty
        # with the given candidates when the loop started may not be in that state when the next iteration runs.
        # Although sending a now-'empty' action would result in a no-op, we can make a (small-ish) optimization by
        # checking the new state of the cell before dispatching any new actions
        if seen_cell.empty? && seen_cell.has_any_of_candidates?(candidates)
          register_change(
            seen_cell_id,
            seen_cell.candidates - candidates,
            action_opts.merge(cascade: cell.id)
          )
        end
      end
    else
      dispatch(
        Action.new(
          type: Action::UPDATE_CELL,
          cell_id: cell_id,
          values: candidates,
          **action_opts
        )
      )
    end
    
    raise unless board.valid?
  end

  private

  attr_reader :reducer
end

