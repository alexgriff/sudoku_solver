class Strategy::HiddenPair < Strategy::BaseStrategy
  extend Strategy::HiddenSubsetN

  def self.execute(board, cell_id)
    hidden_subset_n(2, board, cell_id)
  end

  # def self.execute(board, cell_id)
  #   cell = board.state.get_cell(cell_id)
  #   # are any 2 of my candidates found in one other cell only
  #   if cell.candidates.length >= 2
  #     cell.candidate_permutations(2).each do |cand_pair|    
  #       hidden_pair_cell_ids = cell.houses(board).each_with_object([]) do |house, res|
  #         paired_cell_id = house.other_cell_ids_with_all_of_candidates([cell.id], cand_pair).find do |potential_paired_cell_id|
  #           potential_paired_cell = board.state.get_cell(potential_paired_cell_id)
  #           !house.has_other_cells_with_all_of_candidates?([cell.id, potential_paired_cell.id], [cand_pair[0]]) &&
  #           !house.has_other_cells_with_all_of_candidates?([cell.id, potential_paired_cell.id], [cand_pair[1]])
  #         end
  #         res.concat([paired_cell_id]) if paired_cell_id
  #       end

  #       hidden_pair_cell_ids.each do |paired_cell_id|
  #         hidden_pair_cell = board.state.get_cell(paired_cell_id)
  #         if hidden_pair_cell.candidates != cand_pair
  #           board.state.register_change(
  #             board,
  #             paired_cell_id,
  #             cand_pair,
  #             {strategy: name, pair: [cell.id, paired_cell_id].sort}
  #           )
  #         end
  #       end
  #     end
  #   end
  # end
end
