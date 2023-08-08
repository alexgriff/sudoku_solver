class Strategy::NakedPair < Strategy::BaseStrategy
  def self.execute(board, cell_id)
    cell = board.get_cell(cell_id)
    if cell.candidates.length == 2
      naked_pair_cands = cell.candidates

      paired_cell = board.all_seen_empty_cells_for(cell).find do |seen_cell|
        seen_cell.candidates == naked_pair_cands
      end

      if paired_cell
        interesecting_houses = board.houses_for_cell(cell) & board.houses_for_cell(paired_cell)
        non_paired_cell_ids = interesecting_houses.map(&:empty_cell_ids).flatten - [cell.id, paired_cell.id]
        non_paired_cells = non_paired_cell_ids.map { |cell_id| board.get_cell(cell_id) }
        non_paired_cells.each do |non_paired_cell|
          new_values = non_paired_cell.candidates - naked_pair_cands
          if new_values
            board.reducer.dispatch(
              Action.new(
                type: Action::UPDATE_CELL,
                cell_id: non_paired_cell.id,
                possible_values: new_values,
                naked_pair_cell_id: cell.id,
                strategy: name
              )
            )
          end
        end
      end 
    end
  end
end
