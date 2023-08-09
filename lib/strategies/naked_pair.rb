class Strategy::NakedPair < Strategy::BaseStrategy
  def self.execute(board, cell_id)
    cell = board.get_cell(cell_id)
    if cell.candidates.length == 2
      naked_pair_cands = cell.candidates

      paired_cell_id = board.all_seen_empty_cell_ids_for(cell.id).find do |seen_cell_id|
        board.get_cell(seen_cell_id).candidates == naked_pair_cands
      end

      if paired_cell_id
        paired_cell = board.get_cell(paired_cell_id)
        interesecting_houses = board.houses_for_cell(cell) & board.houses_for_cell(paired_cell)
        non_paired_cell_ids = interesecting_houses.map(&:empty_cell_ids).flatten - [cell.id, paired_cell.id]
        non_paired_cell_ids.each do |non_paired_cell_id|
          # get a fresh cell each iteration in case the previous iteration updates the board
          non_paired_cell = board.get_cell(non_paired_cell_id)

          new_values = non_paired_cell.candidates - naked_pair_cands
          if new_values
            board.update_cell(
              non_paired_cell.id,
              new_values,
              {strategy: name, pair: [cell.id, paired_cell_id].sort}
            )
          end
        end
      end 
    end
  end
end
