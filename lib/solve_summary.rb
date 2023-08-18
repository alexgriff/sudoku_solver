class Solve::Summary
  Strategy::BaseStrategy.subclasses.each do |strategy|
    define_method(:"solved_by_#{strategy.name}_cell_count") do
      history.where(solves: true, strategy: strategy.name).length
    end

    define_method(:"num_#{strategy.name}s") do
      history.where(
        strategy: strategy.name,
        type: Action::UPDATE_CELL,
      ).map(&:strategy_id).uniq.length
    end
  end

  attr_reader :history, :strategies_used

  def initialize(history, strategies_used)
    @history = history
    @strategies_used = strategies_used
  end

  def summarize
    [
      "Solved: #{solved_status}",
      "Cells filled at start: #{initial_filled_cell_count}",
      "Cells initially solveable 'by sudoku' (Naked single): #{solved_by_naked_single_cell_count}",
      used_strategy?(Strategy::HiddenSingle) && "Hidden singles: #{solved_by_hidden_single_cell_count}",
      used_strategy?(Strategy::NakedPair) && "Naked pairs: #{num_naked_pairs}",
      used_strategy?(Strategy::NakedPair) && "  cells solved 'by sudoku' after identifying a naked pair: #{solved_by_naked_pair_cell_count}",
      used_strategy?(Strategy::LockedCandidatesPointing) && "Locked lines: #{num_locked_candidates_pointings}",
      used_strategy?(Strategy::LockedCandidatesPointing) && "  cells solved 'by sudoku' after identifying a locked line in box: #{solved_by_locked_candidates_pointing_cell_count}",
      used_strategy?(Strategy::LockedCandidatesClaiming) && "Claimed lines: #{num_locked_candidates_claimings}",
      used_strategy?(Strategy::LockedCandidatesClaiming) && "  cells solved 'by sudoku' after identifying a claiming line/box: #{solved_by_locked_candidates_claiming_cell_count}",
      used_strategy?(Strategy::NakedTriple) && "Naked triples: #{num_naked_triples}",
      used_strategy?(Strategy::NakedTriple) && "  cells solved 'by sudoku' after identifying a naked triple: #{solved_by_naked_triple_cell_count}",
      used_strategy?(Strategy::NakedQuadruple) && "Naked quadruples: #{num_naked_quadruples}",
      used_strategy?(Strategy::NakedQuadruple) && "  cells solved 'by sudoku' after identifying a naked quadruple: #{solved_by_naked_quadruple_cell_count}",
      used_strategy?(Strategy::HiddenPair) && "Hidden pairs: #{num_hidden_pairs}",
      used_strategy?(Strategy::HiddenPair) && "  cells solved 'by sudoku' after identifying a hidden pair: #{solved_by_hidden_pair_cell_count}",
      used_strategy?(Strategy::XWing) && "X-Wings: #{num_x_wings}",
      used_strategy?(Strategy::XWing) && "  cells solved 'by sudoku' after identifying an x-wing: #{solved_by_x_wing_cell_count}",
      used_strategy?(Strategy::Swordfish) && "Swordfishes: #{num_swordfishs}",
      used_strategy?(Strategy::Swordfish) && "  cells solved 'by sudoku' after identifying a swordfish: #{solved_by_swordfish_cell_count}",
      used_strategy?(Strategy::HiddenTriple) && "Hidden triples: #{num_hidden_triples}",
      used_strategy?(Strategy::HiddenTriple) && "  cells solved 'by sudoku' after identifying a hidden triple: #{solved_by_hidden_triple_cell_count}",
      used_strategy?(Strategy::YWing) && "Y-Wings: #{num_y_wings}",
      used_strategy?(Strategy::YWing) && "  cells solved 'by sudoku' after identifying a y-wing: #{solved_by_y_wing_cell_count}",
      used_strategy?(Strategy::Skyscraper) && "Skyscrapers: #{num_skyscrapers}",
      used_strategy?(Strategy::Skyscraper) && "  cells solved 'by sudoku' after identifying a skyscraper: #{solved_by_skyscraper_cell_count}",
      used_strategy?(Strategy::SimpleColoring) && "Simple Coloring used: #{num_simple_colorings}",
      used_strategy?(Strategy::SimpleColoring) && "  cells solved after identifying the same color was present in the same house: #{solved_by_simple_coloring_same_color_same_house_cell_count}",
      used_strategy?(Strategy::SimpleColoring) && "  cells solved 'by sudoku' after identifying a cell was seen by opposite colors: #{solved_by_simple_coloring_seen_by_opposite_colors_cell_count}",
      "Passes: #{num_passes}",
      "(#{total_count})"
    ].compact.join("\n")
  end

  def total_count
    (
      initial_filled_cell_count +
      solved_by_naked_single_cell_count +
      solved_by_hidden_single_cell_count +
      solved_by_naked_pair_cell_count +
      solved_by_locked_candidates_pointing_cell_count +
      solved_by_locked_candidates_claiming_cell_count +
      solved_by_naked_triple_cell_count +
      solved_by_naked_quadruple_cell_count +
      solved_by_hidden_pair_cell_count +
      solved_by_x_wing_cell_count +
      solved_by_swordfish_cell_count +
      solved_by_hidden_triple_cell_count +
      solved_by_y_wing_cell_count +
      solved_by_skyscraper_cell_count +
      solved_by_simple_coloring_cell_count
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

  # The SimpleColoring reporting methods need to be handrolled since
  # there's two (highly related) different sub-strategies within the SimpleColoring strategy
  def solved_by_simple_coloring_same_color_same_house_cell_count
    history.where(solves: true, strategy: Strategy::SimpleColoring.name, same_color_in_same_house: true).length
  end

  def solved_by_simple_coloring_seen_by_opposite_colors_cell_count
    history.where(solves: true, strategy: Strategy::SimpleColoring.name, seen_by_opposite_colors: true).length
  end
end
