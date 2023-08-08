class Strategy::LockedCandidatesPointing < Strategy::BaseStrategy
  def self.execute(board, cell_id)
    cell = Cell.from_state(id: cell_id, state: board.state[:cells2][cell_id])
    box = Box.for_cell(board, cell)
    potentially_aligned_cands = box.candidate_counts.select { |k, v| v == 2 || v == 3 }.keys
    potentially_aligned_cands_cell_has = cell.candidates & potentially_aligned_cands
    
    aligned_candidates = potentially_aligned_cands_cell_has.each_with_object({}) do |cand, cand_to_line|
      cells_with_cand = box.empty_cells.select { |cell| cell.has_candidate?(cand) }
      if cells_with_cand.all? { |cell| cell.row_id == cells_with_cand.first.row_id }
        cand_to_line[cand] = board.rows[cell.row_id]
      elsif cells_with_cand.all? { |cell| cell.column_id == cells_with_cand.first.column_id }
        cand_to_line[cand] = board.columns[cell.column_id]
      end
    end

    aligned_candidates.each do |candidate, line_house|
      cells_in_line_not_in_box = line_house.empty_cell_ids - box.cell_ids        
      cells_in_line_not_in_box.each do |outside_cell_id|
        outside_cell = board.find_cell(outside_cell_id)
        new_candidates = outside_cell.candidates - [candidate]
        
        if new_candidates != outside_cell.candidates
          locked_alignment_id = "Box-#{box.id}|#{line_house.class.to_s}-#{line_house.id}|#{candidate}"
          if new_candidates.length == 1
            board.reducer.dispatch(
              Action.new(
                type: Action::FILL_CELL,
                cell_id: outside_cell_id,
                value: new_candidates.first,
                strategy: name,
                locked_alignment_id: locked_alignment_id
              )
            )
          else
            board.reducer.dispatch(
              Action.new(
                type: Action::UPDATE_CANDIDATES,
                cell_id: outside_cell_id,
                new_candidates: new_candidates,
                strategy: name,
                locked_alignment_id: locked_alignment_id
              )
            )
          end
        end
      end
    end
  end
end
