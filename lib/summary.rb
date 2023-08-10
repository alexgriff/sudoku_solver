class Summary
  attr_reader :history

  def initialize(history)
    @history = history
  end

  def summarize
    [
      "\n",
      "Solved: #{solved_status}",
      "Filled cells at start: #{initial_filled_cell_count}",
      "Cells solveable 'by sudoku' (naked single): #{naked_single_cell_count}",
      "Hidden singles: #{hidden_single_cell_count}",
      "Naked pairs: #{num_naked_pairs}",
      "Cells solveable 'by sudoku' after identifying naked pair: #{solved_by_naked_pair_cell_count}",
      "Lines with locked, aligned candidates in same box: #{num_locked_pointing_lines}",
      "Cells solveable 'by sudoku' after identifying locked, aligned candidates: #{solved_by_locked_pointing_cell_count}",
      "Lines with 'claimed' candidate from box intersecting two locked candidate lines: #{num_claimed_lines}",
      "Cells solveable 'by sudoku' after identifying 'claiming' line/box: #{solved_by_claiming_lines_cell_count}",
      "Hidden pairs: #{num_hidden_pairs}",
      "Passes: #{num_passes}",
      total_count
    ].compact.join("\n")
  end

  def total_count
    (
      initial_filled_cell_count +
      naked_single_cell_count +
      hidden_single_cell_count +
      solved_by_naked_pair_cell_count +
      solved_by_locked_pointing_cell_count +
      solved_by_claiming_lines_cell_count
    )
  end

  def solved_status
    history.find(type: Action::DONE).status
  end

  def num_passes
    history.where(type: Action::NEW_PASS).length
  end

  def initial_filled_cell_count
    history.find(type: Action::NEW_BOARD_SYNC).initial_data.reject { |v| v == Cell::EMPTY }.length
  end

  def naked_single_cell_count
    history.where(type: Action::FILL_CELL, strategy: Strategy::NakedSingle.name).length
  end

  def hidden_single_cell_count
    history.where(type: Action::FILL_CELL, strategy: Strategy::HiddenSingle.name).length
  end

  def num_naked_pairs
    history.where(
      strategy: Strategy::NakedPair.name,
      type: Action::UPDATE_CELL,
    ).map(&:pair).uniq.length
  end

  def solved_by_naked_pair_cell_count
    history.where(type: Action::FILL_CELL, strategy: Strategy::NakedPair.name).length
  end

  def num_locked_pointing_lines
    history.where(
      strategy: Strategy::LockedCandidatesPointing.name,
      type: Action::UPDATE_CELL,
    ).map(&:locked_alignment_id).uniq.length
  end

  def solved_by_locked_pointing_cell_count
    history.where(type: Action::FILL_CELL, strategy: Strategy::LockedCandidatesPointing.name).length
  end
  
  def num_claimed_lines
    history.where(
      strategy: Strategy::LockedCandidatesClaiming.name,
      type: Action::UPDATE_CELL,
    ).map(&:claiming_box_id).uniq.length
  end

  def solved_by_claiming_lines_cell_count
    history.where(type: Action::FILL_CELL, strategy: Strategy::LockedCandidatesClaiming.name).length
  end

  def num_hidden_pairs
    history.where(
      strategy: Strategy::HiddenPair.name,
      type: Action::UPDATE_CELL
    ).map(&:pair).uniq.length
  end
end