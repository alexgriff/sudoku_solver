class Strategy::LockedCandidatesClaiming < Strategy::BaseStrategy
  def self.execute(board, cell)
    row = cell.row(board)
    col = cell.column(board)
    box = cell.box(board)
    
    (cell.candidates - box.uniq_candidates).each do |cand|
      # if cand is in found in 2 rows only is there another box with cand in same 2 rows
      cand_rows = box.cells_with_all_of_candidates([cand]).map { |c| c.row(board) }.uniq    
      if cand_rows.length == 2
        matched_box = (row.boxes - [box]).find do |other_box|
          cand_cells_other_box = other_box.cells_with_all_of_candidates([cand])
          cand_rows.map(&:id) == cand_cells_other_box.map(&:row_id).uniq
        end
        
        # if so, third box cant have the cand in those rows
        if matched_box
          third_box = (row.boxes - [box, matched_box]).first

          third_box.cells_with_all_of_candidates([cand]).select do |third_box_cell|
            cand_rows.map(&:id).include?(third_box_cell.row_id)
          end.each do |third_box_cell|
            new_candidates = third_box_cell.candidates - [cand]
            if cell.will_change?(new_candidates)
              board.state.register_change(
                board,
                third_box_cell,
                new_candidates,
                {strategy: name, claiming_box_id: "Box-#{third_box.id}|Row-#{cand_rows.map(&:id)}|Locked-#{cand}"}
              )
            end
          end
        end
      end

      # if cand is in found in 2 cols only is there another box with cand in same 2 cols
      cand_cols = box.cells_with_all_of_candidates([cand]).map { |c| c.column(board) }.uniq   
      if cand_cols.length == 2
        matched_box = (col.boxes - [box]).find do |other_box|
          cand_cells_other_box = other_box.cells_with_all_of_candidates([cand])
          cand_cols.map(&:id) == cand_cells_other_box.map(&:column_id).uniq
        end

        # if so, third box cant have the cand in those cols
        if matched_box
          third_box = (col.boxes - [box, matched_box]).first

          third_box.cells_with_all_of_candidates([cand]).select do |third_box_cell|
            cand_cols.map(&:id).include?(third_box_cell.column_id)
          end.each do |third_box_cell|
            new_candidates = third_box_cell.candidates - [cand]
            if cell.will_change?(new_candidates)
              board.state.register_change(
                board,
                third_box_cell,
                new_candidates,
                {strategy: name, claiming_box_id: "Box-#{third_box.id}|Cols-#{cand_cols.map(&:id)}|Locked-#{cand}"}
              )
            end
          end
        end
      end 
    end
  end
end
