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

  module NakedGroupN
    def naked_group_n(n, board, cell_id)
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
end
