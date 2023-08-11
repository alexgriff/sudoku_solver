module Strategy
  class BaseStrategy
    attr_reader :name

    def self.name
      self.to_s.split('::').last.downcase.to_sym
    end

    def self.apply(board)
      board.empty_cell_ids.each do |id|
        execute(board, id)
      end
      true
    end
  end

  module NakedSubsetN
    def naked_subset_n(n, board, cell_id)
      cell = board.state.get_cell(cell_id)

      if cell.candidates.length == n
        naked_buddy_candidates = cell.candidates
        cell.houses(board).each do |house|
          naked_buddy_ids = house.cell_ids_with_any_of_candidates(
            naked_buddy_candidates
          ).reject do |naked_buddy_id|
            (board.state.get_cell(naked_buddy_id).candidates - naked_buddy_candidates).any?
          end

          if naked_buddy_ids.length == n
            house.other_cell_ids(naked_buddy_ids).each do |non_buddied_cell_id|
              non_buddied_cell = board.state.get_cell(non_buddied_cell_id)
              new_values = non_buddied_cell.candidates - naked_buddy_candidates
                if new_values != non_buddied_cell.candidates
                  board.state.register_change(
                    board,
                    non_buddied_cell.id,
                    new_values,
                    {strategy: name, naked_buddies: naked_buddy_ids.sort}
                  )
                end
            end
          end
        end
      end
    end
  end


  module HiddenSubsetN
    def hidden_subset_n(n, board, cell_id)
      cell = board.state.get_cell(cell_id)

      # are any n of my candidates found in exactly n cells
      if cell.candidates.length >= n
        cell.houses(board).each do |house|
          cell = board.state.get_cell(cell_id) # get a fresh cell at the start of the loop
          next if (cell.candidates.intersection(house.uniq_candidates)).any? # a hidden single is handled separately
          
          cell.candidate_permutations(n).each do |cand_permutation|            
            hidden_buddy_ids = house.cell_ids_with_any_of_candidates(cand_permutation)
            if hidden_buddy_ids.length == n
              hidden_buddy_ids.each do |hidden_buddy_id|
                hidden_buddy_cell = board.state.get_cell(hidden_buddy_id)
                new_values =  hidden_buddy_cell.candidates.intersection(cand_permutation)

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
end
