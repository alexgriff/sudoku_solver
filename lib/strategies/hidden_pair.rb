class Strategy::HiddenPair < Strategy::BaseStrategy
  def self.execute(board, cell_id)
    cell = board.get_cell(cell_id)
    # are any 2 of my candidates found in one other cell only
    if cell.candidates.length >= 2
      cell.candidate_permutations(2).each do |cand_pair|    
        hidden_pair_cell_ids = board.houses_for_cell(cell).each_with_object([]) do |house, res|
          paired_cell = house.other_cells_with_candidates([cell.id], cand_pair).find do |potential_paired_cell|
            potential_paired_cell.candidates.length > 2 &&
            !house.any_other_cells_with_candidates?([cell.id, potential_paired_cell.id], [cand_pair[0]]) &&
            !house.any_other_cells_with_candidates?([cell.id, potential_paired_cell.id], [cand_pair[1]])
          end
          res << paired_cell.id if paired_cell
          res
        end
        
        hidden_pair_cell_ids.each do |paired_cell_id|
          # get a fresh cell each iteration in case the previous iteration updates the board
          paired_cell = board.get_cell(paired_cell_id)

          board.update_cell(
            paired_cell.id,
            cand_pair,
            {strategy: name, pair: [cell.id, paired_cell.id].sort}
          )
        end
      end
    end
  end
end
