module Strategy
  class BaseStrategy
    attr_reader :name

    def self.name
      self.to_s.split('::').last.downcase.to_sym
    end

    def self.apply(board)
      board.empty_cells.each do |cell|
        execute(board, cell)
      end
      true
    end
  end

  module NakedSubsetN
    def naked_subset_n(n, board, cell)
      if cell.candidates.length == n
        naked_buddy_candidates = cell.candidates

        cell.houses(board).each do |house|
          naked_buddy_cells = house.cells_with_any_of_candidates(naked_buddy_candidates).reject do |other_cell|
            (other_cell.candidates - naked_buddy_candidates).any?
          end

          if naked_buddy_cells.length == n
            house.other_cells([naked_buddy_cells]).each do |non_buddied_cell|
              board.state.register_change(
                board,
                non_buddied_cell,
                non_buddied_cell.candidates - naked_buddy_candidates,
                {strategy: name, naked_buddies: naked_buddy_cells.map(&:id)}
              )
            end
          end
        end
      end
    end
  end


  module HiddenSubsetN
    def hidden_subset_n(n, board, cell)

      # are any n of my candidates found in exactly n cells
      if cell.candidates.length >= n
        cell.houses(board).each do |house|
          next if (cell.candidates.intersection(house.uniq_candidates)).any? # a hidden single is handled separately
          
          cell.candidate_permutations(n).each do |cand_permutation|            
            hidden_buddys = house.cells_with_any_of_candidates(cand_permutation)
            if hidden_buddys.length == n
              hidden_buddys.each do |hidden_buddy_cell|
                board.state.register_change(
                  board,
                  hidden_buddy_cell,
                  hidden_buddy_cell.candidates.intersection(cand_permutation),
                  {strategy: name, hidden_buddies: hidden_buddys.map(&:id)}
                )
              end
            end
          end
        end
      end
    end
  end
end
