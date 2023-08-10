class Board::State
  def self.clone_from(other_state)
    new(
      other_state.instance_variable_get(:@touched),
      other_state.instance_variable_get(:@passes),
      other_state.instance_variable_get(:@solved).dup,
      other_state.instance_variable_get(:@cells).dup,
      Action::CLONE
    )
  end

  attr_reader :history

  def initialize(touched=nil, passes=nil, solved=nil, cells=nil, init_action_type=Action::INIT)
    @touched = touched
    @passes = passes
    @solved = solved
    @cells = cells

    @history = Board::History.new

    dispatch(Action.new(type: init_action_type))
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

  def dispatch(action)
    history << action
    self.touched = Board::Reducer.touched_reducer({touched: @touched, cells: @cells}, action)
    self.passes = Board::Reducer.passes_reducer(@passes, action)
    self.solved = Board::Reducer.solved_reducer(@solved, action)
    self.cells = Board::Reducer.cells_reducer(@cells, action)
  end

  def register_next_pass
    dispatch(Action.new(type: Action::NEW_PASS))
  end

  def register_done
    dispatch(Action.new(type: Action::DONE, status: is_solved?))
  end

  def register_starting_state(initial_data, seen_cell_ids_map)
    dispatch(
      Action.new(
        type: Action::NEW_BOARD_SYNC,
        initial_data: initial_data,
        seen_cell_ids_map: seen_cell_ids_map,
      )
    )
  end

  def register_change(board, cell_id, candidates, action_opts={})
    cell = get_cell(cell_id)
    solving = cell.empty? && candidates.length == 1

    if solving
      dispatch(
        Action.new(
          type: Action::UPDATE_CELL,
          cell_id: cell_id,
          values: [candidates.first],
          solves: true,
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
            board,
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
    
    raise Board::State::InvalidError unless board.valid?
  end

  class InvalidError < StandardError; end

  private

  attr_writer :touched, :passes, :solved, :cells
end

