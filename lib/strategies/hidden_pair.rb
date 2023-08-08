class Strategy::HiddenPair < Strategy::BaseStrategy
  def self.execute(board, cell_id)
    cell = board.find_cell(cell_id)
    # are any 2 of my candidates found in one other cell only
    if cell.candidates.length >= 2
      row = Row.for_cell(board, cell)
      col = Column.for_cell(board, cell)
      box = Box.for_cell(board, cell)

      cell.candidate_permutations(2).each do |cand_pair|
        hidden_pair_cells = [row, col, box].each_with_object([]) do |house, res|
          paired_cell = house.other_cells_with_candidates([cell.id], cand_pair).find do |potential_paired_cell|
            potential_paired_cell.candidates.length > 2 &&
            house.other_cells_with_candidates([cell.id, potential_paired_cell.id], [cand_pair[0]]).length == 0 &&
            house.other_cells_with_candidates([cell.id, potential_paired_cell.id], [cand_pair[1]]).length == 0
          end
          res << paired_cell if paired_cell
          res
        end

        hidden_pair_cells.each do |paired_cell|
          board.reducer.dispatch(
            Action.new(
              type: Action::UPDATE_CANDIDATES,
              cell_id: paired_cell.id,
              new_candidates: cand_pair,
              paired_cell_id: cell.id,
              strategy: name
            )
          )
        end
      end
    end
  end
end
