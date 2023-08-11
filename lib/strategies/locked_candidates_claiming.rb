class Strategy::LockedCandidatesClaiming < Strategy::BaseStrategy
  def self.execute(board, cell_id)
    cell = board.state.get_cell(cell_id)
    row = cell.row(board)
    col = cell.column(board)
    box = cell.box(board)
    
    (cell.candidates - box.uniq_candidates).each do |cand|
      # if cand is in found in 2 rows only is there another box with cand in same 2 rows
      cand_row_ids = box.cell_ids_with_all_of_candidates([cand]).map { |id| board.state.get_cell(id).row_id }.uniq    
      if cand_row_ids.length == 2
        matched_box_id = (row.box_ids - [box.id]).find do |other_box_id|
          other_box = board.boxes[other_box_id]
          cand_cell_ids_other_box = other_box.cell_ids_with_all_of_candidates([cand])
          cand_row_ids == cand_cell_ids_other_box.map { |id| board.state.get_cell(id).row_id }.uniq
        end
        
        # if so, third box cant have the cand in those rows
        if matched_box_id
          third_box = board.boxes[(row.box_ids - [box.id, matched_box_id]).first]

          third_box.cell_ids_with_all_of_candidates([cand]).select do |third_box_cell_id|
            cand_row_ids.include?(Cell.new(id: third_box_cell_id).row_id)
          end.each do |third_box_cell_id|
            third_box_cell = board.state.get_cell(third_box_cell_id)
            new_candidates = third_box_cell.candidates - [cand]
            if new_candidates != third_box_cell.candidates
              board.state.register_change(
                board,
                third_box_cell.id,
                new_candidates,
                {strategy: name, claiming_box_id: "Box-#{third_box.id}|Row-#{cand_row_ids}|Locked-#{cand}"}
              )
            end
          end
        end
      end

      # if cand is in found in 2 cols only is there another box with cand in same 2 cols
      cand_col_ids = box.cell_ids_with_all_of_candidates([cand]).map { |id| board.state.get_cell(id).column_id }.uniq
      if cand_col_ids.length == 2
        matched_box_id = (col.box_ids - [box.id]).find do |other_box_id|
          other_box = board.boxes[other_box_id]
          cand_cell_ids_other_box = other_box.cell_ids_with_all_of_candidates([cand])
          cand_col_ids == cand_cell_ids_other_box.map { |id| board.state.get_cell(id).column_id }.uniq
        end

        # if so, third box cant have the cand in those cols
        if matched_box_id
          third_box = board.boxes[(col.box_ids - [box.id, matched_box_id]).first]

          third_box.cell_ids_with_all_of_candidates([cand]).select do |third_box_cell_id|
            cand_col_ids.include?(Cell.new(id: third_box_cell_id).column_id)
          end.each do |third_box_cell_id|
            third_box_cell = board.state.get_cell(third_box_cell_id)
            new_candidates = third_box_cell.candidates - [cand]
            if new_candidates != third_box_cell.candidates
              board.state.register_change(
                board,
                third_box_cell.id,
                new_candidates,
                {strategy: name, claiming_box_id: "Box-#{third_box.id}|Cols-#{cand_col_ids}|Locked-#{cand}"}
              )
            end
          end
        end
      end 
    end
  end
end
