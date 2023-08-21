class Strategy::YWing < Strategy::BaseStrategy
  def self.apply(board)
    board.each_empty_cell do |pivot_cell|
      if pivot_cell.candidates.length == 2
        # looking for a pattern of 3 cells all with 2 candidates each
        # where the value of those canidates follows a pattern like AB, AC, BC
        # and one cell, 'the pivot', can see the other 2, the 'pincers'.
        first_pincer = board.empty_cells_seen_by(pivot_cell).find do |seen_cell|
          seen_cell.candidates.length == 2 &&
          seen_cell.candidates.intersection(pivot_cell.candidates).length == 1
        end

        if first_pincer
          second_pincer_expected_candidates = (
            pivot_cell.candidates.union(first_pincer.candidates) - pivot_cell.candidates.intersection(first_pincer.candidates)
          ).sort
          second_pincer = (board.empty_cells_seen_by(pivot_cell) - board.empty_cells_seen_by(first_pincer)).find do |seen_cell|
            seen_cell.candidates == second_pincer_expected_candidates
          end

          if second_pincer
            eliminateable_cand = first_pincer.candidates.intersection(second_pincer.candidates)
            board.each_cell_with_candidates(
              board.cells_seen_by(first_pincer).intersection(board.cells_seen_by(second_pincer)),
              eliminateable_cand
            ) do |cell|
              board.state.register_change(
                board,
                cell,
                cell.candidates - eliminateable_cand,
                {strategy: name, strategy_application_id: "#{[pivot_cell.id, first_pincer.id, second_pincer.id].sort.join('-')}|#{eliminateable_cand.first}"}
              )
            end
          end
        end
      end
    end
  end
end
