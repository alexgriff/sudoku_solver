class Solve::Summary
  attr_reader :history, :strategies_used

  def initialize(history, strategies_used)
    @history = history
    @strategies_used = strategies_used
  end

  def summarize
    [
      "Solved: #{solved_status}",
      "Cells filled at start: #{initial_filled_cell_count}",
      "Cells initially solveable 'by sudoku' (Naked single): #{naked_single_cell_count}",
      used_strategy?(Strategy::HiddenSingle) && "Hidden singles: #{hidden_single_cell_count}",
      used_strategy?(Strategy::NakedPair) && "Naked pairs: #{num_naked_pairs}",
      used_strategy?(Strategy::NakedPair) && "  cells solved 'by sudoku' after identifying naked pair: #{solved_by_naked_pair_cell_count}",
      used_strategy?(Strategy::LockedCandidatesPointing) && "Locked lines: #{num_locked_pointing_lines}",
      used_strategy?(Strategy::LockedCandidatesPointing) && "  cells solved 'by sudoku' after locked line in box: #{solved_by_locked_pointing_cell_count}",
      used_strategy?(Strategy::LockedCandidatesClaiming) && "Claimed lines: #{num_claimed_lines}",
      used_strategy?(Strategy::LockedCandidatesClaiming) && "  cells solved 'by sudoku' after identifying 'claiming' line/box: #{solved_by_claiming_lines_cell_count}",
      used_strategy?(Strategy::NakedTriple) && "Naked triples: #{num_naked_triples}",
      used_strategy?(Strategy::NakedTriple) && "  cells solved 'by sudoku' after identifying a naked triple: #{solved_by_naked_triple_cell_count}",
      used_strategy?(Strategy::NakedQuadruple) && "Naked quadruples: #{num_naked_quadruples}",
      used_strategy?(Strategy::NakedQuadruple) && "  cells solved 'by sudoku' after identifying a naked quadruple: #{solved_by_naked_quadruple_cell_count}",
      used_strategy?(Strategy::HiddenPair) && "Hidden pairs: #{num_hidden_pairs}",
      used_strategy?(Strategy::HiddenPair) && "  cells solved 'by sudoku' after identifying a hidden pair: #{solved_by_hidden_pair_cell_count}",
      used_strategy?(Strategy::XWing) && "X-Wings: #{num_x_wings}",
      used_strategy?(Strategy::XWing) && "  cells solved 'by sudoku' after identifying an x-wing: #{solved_by_x_wing_cell_count}",
      used_strategy?(Strategy::Swordfish) && "Swordfishes: #{num_swordfish}",
      used_strategy?(Strategy::Swordfish) && "  cells solved 'by sudoku' after identifying a swordfish: #{solved_by_swordfish_cell_count}",
      used_strategy?(Strategy::HiddenTriple) && "Hidden triples: #{num_hidden_triples}",
      used_strategy?(Strategy::HiddenTriple) && "  cells solved 'by sudoku' after identifying a hidden triple: #{solved_by_hidden_triple_cell_count}",
      used_strategy?(Strategy::YWing) && "Y-Wings: #{num_y_wings}",
      used_strategy?(Strategy::YWing) && "  cells solved 'by sudoku' after identifying a y-wing: #{solved_by_y_wing_cell_count}",
      used_strategy?(Strategy::Skyscraper) && "Skyscrapers: #{num_skyscrapers}",
      used_strategy?(Strategy::Skyscraper) && "  cells solved 'by sudoku' after identifying a skyscraper: #{solved_by_skyscraper_cell_count}",
      "Passes: #{num_passes}",
      "(#{total_count})"
    ].compact.join("\n")
  end

  def total_count
    (
      initial_filled_cell_count +
      naked_single_cell_count +
      hidden_single_cell_count +
      solved_by_naked_pair_cell_count +
      solved_by_locked_pointing_cell_count +
      solved_by_claiming_lines_cell_count +
      solved_by_naked_triple_cell_count +
      solved_by_naked_quadruple_cell_count +
      solved_by_hidden_pair_cell_count +
      solved_by_x_wing_cell_count +
      solved_by_swordfish_cell_count +
      solved_by_hidden_triple_cell_count +
      solved_by_y_wing_cell_count +
      solved_by_skyscraper_cell_count
    )
  end

  def used_strategy?(strategy)
    strategies_used.include?(strategy) || nil
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
    history.where(solves: true, strategy: Strategy::NakedSingle.name).length
  end

  def hidden_single_cell_count
    history.where(solves: true, strategy: Strategy::HiddenSingle.name).length
  end

  def num_naked_pairs
    history.where(
      strategy: Strategy::NakedPair.name,
      type: Action::UPDATE_CELL,
    ).map(&:naked_buddies).uniq.length
  end

  def solved_by_naked_pair_cell_count
    history.where(solves: true, strategy: Strategy::NakedPair.name).length
  end

  def num_locked_pointing_lines
    history.where(
      strategy: Strategy::LockedCandidatesPointing.name,
      type: Action::UPDATE_CELL,
    ).map(&:locked_alignment_id).uniq.length
  end

  def solved_by_locked_pointing_cell_count
    history.where(solves: true, strategy: Strategy::LockedCandidatesPointing.name).length
  end

  def num_claimed_lines
    history.where(
      strategy: Strategy::LockedCandidatesClaiming.name,
      type: Action::UPDATE_CELL,
    ).map(&:claiming_box_id).uniq.length
  end

  def solved_by_claiming_lines_cell_count
    history.where(solves: true, strategy: Strategy::LockedCandidatesClaiming.name).length
  end

  def num_naked_triples
    history.where(
      strategy: Strategy::NakedTriple.name,
      type: Action::UPDATE_CELL,
    ).map(&:naked_buddies).uniq.length
  end

  def solved_by_naked_triple_cell_count
    history.where(solves: true, strategy: Strategy::NakedTriple.name).length
  end

  def num_naked_quadruples
    history.where(
      strategy: Strategy::NakedQuadruple.name,
      type: Action::UPDATE_CELL,
    ).map(&:naked_buddies).uniq.length
  end

  def solved_by_naked_quadruple_cell_count
    history.where(solves: true, strategy: Strategy::NakedQuadruple.name).length
  end

  def num_hidden_pairs
    history.where(
      strategy: Strategy::HiddenPair.name,
      type: Action::UPDATE_CELL
    ).map(&:hidden_buddies).uniq.length
  end

  def solved_by_hidden_pair_cell_count
    history.where(solves: true, strategy: Strategy::HiddenPair.name).length
  end

  def num_hidden_triples
    history.where(
      strategy: Strategy::HiddenTriple.name,
      type: Action::UPDATE_CELL,
    ).map(&:hidden_buddies).uniq.length
  end

  def solved_by_hidden_triple_cell_count
    history.where(solves: true, strategy: Strategy::HiddenTriple.name).length
  end

  def num_x_wings
    history.where(
      strategy: Strategy::XWing.name,
      type: Action::UPDATE_CELL,
    ).map(&:fish_id).uniq.length
  end

  def solved_by_x_wing_cell_count
    history.where(solves: true, strategy: Strategy::XWing.name).length
  end

  def num_swordfish
    history.where(
      strategy: Strategy::Swordfish.name,
      type: Action::UPDATE_CELL,
    ).map(&:fish_id).uniq.length
  end

  def solved_by_swordfish_cell_count
    history.where(solves: true, strategy: Strategy::Swordfish.name).length
  end

  def num_y_wings
    history.where(
      strategy: Strategy::YWing.name,
      type: Action::UPDATE_CELL,
    ).map(&:y_wing_id).uniq.length
  end

  def solved_by_y_wing_cell_count
    history.where(solves: true, strategy: Strategy::YWing.name).length
  end

  def num_skyscrapers
    history.where(
      strategy: Strategy::Skyscraper.name,
      type: Action::UPDATE_CELL,
    ).map(&:skyscraper).uniq.length
  end

  def solved_by_skyscraper_cell_count
    history.where(solves: true, strategy: Strategy::Skyscraper.name).length
  end
end
