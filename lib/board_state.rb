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
    self.touched = Board::Reducer.touched_reducer({touched: @touched, cells: @cells}, action)
    self.passes = Board::Reducer.passes_reducer(@passes, action)
    self.solved = Board::Reducer.solved_reducer(@solved, action)
    self.cells = Board::Reducer.cells_reducer(@cells, action)
    history << action
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

  def register_change(board, cell, new_candidates, action_opts={})
    return unless cell.will_change?(new_candidates)
    solving = cell.empty? && new_candidates.length == 1
    if solving
      action = Action.new(
        type: Action::UPDATE_CELL,
        cell_id: cell.id,
        values: [new_candidates.first],
        solves: true,
        **action_opts
      )
      dispatch(action)

      board.each_empty_cell(
        board.empty_cells_seen_by(cell).intersection(board.cells_with_candidates(new_candidates))
      ) do |seen_cell|
        register_change(
          board,
          seen_cell,
          seen_cell.candidates - new_candidates,
          action_opts.merge(cascaded_from_id: action.id)
        )
      end
    else
      dispatch(
        Action.new(
          type: Action::UPDATE_CELL,
          cell_id: cell.id,
          values: new_candidates,
          **action_opts
        )
      )
    end

    raise InvalidError.new(board) unless board.valid?
  end

  def reset_to(action)
    copied_history = history.up_to(action.id)
    history.reset
    copied_history.each do |action|
      dispatch(action)
    end
  end

  def undo(action)
    reset_to(history.action_previous_to(action)) if action
  end

  class InvalidError < StandardError
    def initialize(board)
      super("Board: #{board.id}\n#{board.errors.join("\n")}")
    end
  end

  private

  attr_writer :touched, :passes, :solved, :cells
end

