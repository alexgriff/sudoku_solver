class Strategy::LockedCandidatesPointing < Strategy::BaseStrategy
  def self.execute(board, cell_id)
    cell = board.state.get_cell(cell_id)
    box = cell.box(board)
    cands_with_multiple_in_box = box.candidate_counts.select { |k, v| v == 2 || v == 3 }.keys
    cell_cands_present_in_other_box_cells = cell.intersecting_candidates(cands_with_multiple_in_box)
    
    cand_to_line_map = cell_cands_present_in_other_box_cells.each_with_object({}) do |cand, res|
      all_box_cell_ids_with_cand = box.empty_cell_ids.select { |cell_id| board.state.get_cell(cell_id).has_any_of_candidates?([cand]) }
      
      # are all the cands in the same row
      if all_box_cell_ids_with_cand.all? { |box_cell_id| board.state.get_cell(box_cell_id).row_id == cell.row_id }
        res[cand] = board.rows[cell.row_id]
      
       # are all the cands in the same col
      elsif all_box_cell_ids_with_cand.all? { |box_cell_id| board.state.get_cell(box_cell_id).column_id == cell.column_id }
        res[cand] = board.columns[cell.column_id]
      end
    end

    cand_to_line_map.each do |cand, line_house|
      line_cell_ids_outside_box = line_house.empty_other_cell_ids(box.cell_ids)

      line_cell_ids_outside_box.each do |outside_box_cell_id|
        outside_box_cell = board.state.get_cell(outside_box_cell_id)
        new_candidates = outside_box_cell.candidates - [cand]
        
        if new_candidates != outside_box_cell.candidates
          board.state.register_change(
            outside_box_cell.id,
            new_candidates,
            {strategy: name, locked_alignment_id: "Box-#{box.id}|#{line_house.class.to_s}-#{line_house.id}|#{cand}"}
          )
        end
      end
    end
  end
end
