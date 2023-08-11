class Strategy::HiddenPair < Strategy::BaseStrategy
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
  def self.execute(board, cell_id)
    cell = board.state.get_cell(cell_id)
    
    # are any n of my candidates found in exactly n cells
    if cell.candidates.length >= 2
      cell.candidate_permutations(2).each do |cand_permutation|
        cell.houses(board).each do |house|
          hidden_buddy_ids = house.cell_ids_with_any_of_candidates(cand_permutation)
          # issue is here ^, this is identifying a two cells like
          # (2,5,6,8) and (1,5,6,8) as having in common the permutation [1,6]
          # (1 only shows up in board in this one cell, it should get picked up as hidden single on next pass)
          
          # what i dont understand is how to specify how/why this rule is different
          # in the pair vs triple/(etc) case. For ex, 3 cells like
          # (4,5) (1,2,4,5) and (2,5,6) would be a hidden triple even tho each cell doesnt have all of the cands
          # how to describe these rules as the same thing... they feel different

          if hidden_buddy_ids.length == 2
            hidden_buddy_ids.each do |hidden_buddy_id|
              hidden_buddy_cell = board.state.get_cell(hidden_buddy_id)
              new_values =  hidden_buddy_cell.candidates.intersection(cand_permutation) 
              debugger if hidden_buddy_id == 33 && hidden_buddy_ids == [33, 42]
              
              if hidden_buddy_cell.candidates != new_values
                board.state.register_change(
                  board,
                  hidden_buddy_id,
                  new_values,
                  {strategy: name, hidden_buddies: hidden_buddy_ids.sort}
                )
              end
            end
          end
        end
      end
    end
  end
end
