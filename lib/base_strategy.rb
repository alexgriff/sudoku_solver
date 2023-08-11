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
        cell.candidate_permutations(n).each do |cand_permutation|
          cell.houses(board).each do |house|
            next if (cell.candidates.intersection(house.uniq_candidates)).any?
            # this ^ fixes the issue below, but is there a better way to do this?
            # does this same idea (looking out for a hidden single) need to be applied elsewhere
            # probs not - tho this could make u wanna look for all hidden ns altogether in one group

            hidden_buddy_ids = house.cell_ids_with_any_of_candidates(cand_permutation)
            # issue is here ^, this is identifying a two cells like
            # (2,5,6,8) and (1,5,6,8) as having in common the pair (1,6)
            # (1 only shows up in board in this one cell, it should get picked up as hidden single on next pass)

            # what i dont understand is how to specify how/why this rule is different
            # in the pair vs triple/(etc) case. For ex, 3 cells like
            # (4,5) (1,2,4,5) and (2,5,6) would be a hidden triple even tho each cell doesnt have all of the cands
            # how to describe these rules as the same thing... they feel different, are they just different

            # is it that in a hidden-n, you actually need to check that it's not a hidden-n-minus-one
            # for example, you wouldn't want to mark the following as a hidden triple
            # (1,2,4,5) (4,5) (4,5) either (1,4,5) or (2,4,5)

            # so is the rule just that none of the hidden-n cells can have a uniq candidate, i think this would scale upward

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
