class Board::State
  attr_reader :history

  def initialize
    @touched = nil
    @passes = nil
    @solved = nil
    @cells = nil

    @history = Board::History.new

    dispatch(Action.new(type: Action::INIT))
  end

  def get_cell_value(id)
    @solved[id] || Cell::EMPTY
  end

  def get_cell_candidates(id)
    @solved[id] ? [] : @cells[id]
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

  def register_change(board, cell, candidates, action_opts={})
    solving = cell.empty? && candidates.length == 1
    if solving
      dispatch(
        Action.new(
          type: Action::UPDATE_CELL,
          cell_id: cell.id,
          values: [candidates.first],
          solves: true,
          **action_opts
        )
      )
      board.all_empty_cells_with_any_of_candidates_seen_by(cell, candidates).each do |seen_cell|
        if seen_cell.empty? && seen_cell.has_any_of_candidates?(candidates)
          register_change(
            board,
            seen_cell,
            seen_cell.candidates - candidates,
            action_opts.merge(cascade: cell.id)
          )
        end
      end
    else
      dispatch(
        Action.new(
          type: Action::UPDATE_CELL,
          cell_id: cell.id,
          values: candidates,
          **action_opts
        )
      )
    end

    raise InvalidError.new(board) unless board.valid?
  end

  class InvalidError < StandardError
    def initialize(board)
      super(board.errors.join("\n"))
    end
  end

  private

  attr_writer :touched, :passes, :solved, :cells
end

