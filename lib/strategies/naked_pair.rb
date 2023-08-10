class Strategy::NakedPair < Strategy::BaseStrategy
  def self.execute(board, cell_id)
    cell = board.state.get_cell(cell_id)
    if cell.candidates.length == 2
      naked_pair_cands = cell.candidates

      paired_cell_id = board.all_empty_cell_ids_seen_by(cell.id).find do |seen_cell_id|
        board.state.get_cell(seen_cell_id).candidates == naked_pair_cands
      end

      if paired_cell_id
        paired_cell = board.state.get_cell(paired_cell_id)
        interesecting_houses = cell.houses(board) & paired_cell.houses(board)
        non_paired_cell_ids = interesecting_houses.map(&:empty_cell_ids).flatten - [cell.id, paired_cell.id]
        non_paired_cell_ids.each do |non_paired_cell_id|
          non_paired_cell = board.state.get_cell(non_paired_cell_id)

          new_values = non_paired_cell.candidates - naked_pair_cands
          if new_values
            board.state.register_change(
              board,
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
