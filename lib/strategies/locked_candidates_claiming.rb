class Strategy::LockedCandidatesClaiming < Strategy::BaseStrategy
  def self.execute(board, cell_id)
    cell = board.get_cell(cell_id)
    row = Row.for_cell(board, cell)
    col = Column.for_cell(board, cell)
    box = Box.for_cell(board, cell)
    
    cand_with_multiple_in_box = box.candidate_counts.select { |k, v| v >= 2 }.keys
    cell_cands_present_in_other_box_cells = cell.candidates & cand_with_multiple_in_box
    
    # find candidate that is only in 2 rows/cols in box
    cell_cands_present_in_other_box_cells.each do |cand|
      box_cells_with_cand = box.cells_with_candidates([cand])
      locked_cand_row_ids = box_cells_with_cand.map(&:row_id).uniq
      locked_cand_col_ids = box_cells_with_cand.map(&:column_id).uniq
      
      # if in only 2 rows is there another box with same cand row ids
      if locked_cand_row_ids.length == 2
        other_box_ids = row.box_ids - [box.id]
        matched_box_id = other_box_ids.find do |other_box_id|
          other_box = board.boxes[other_box_id]
          cand_cells_other_box = other_box.cells_with_candidates([cand])
          locked_cand_row_ids == cand_cells_other_box.map(&:row_id).uniq
        end
        
        # if so, third box cant have the cand in those rows
        if matched_box_id
          third_box_id = (other_box_ids - [matched_box_id]).first
          third_box = board.boxes[third_box_id]

          third_box.cells_with_candidates([cand]).each do |third_box_cell|
            if locked_cand_row_ids.include?(third_box_cell.row_id)
              new_candidates = third_box_cell.candidates - [cand]
              if new_candidates != third_box_cell.candidates
                board.update_cell(
                  third_box_cell.id,
                  new_candidates,
                  {strategy: name, claiming_box_id: "Box-#{third_box.id}|Row-#{row.id}|#{cand}"}
                )
              end
            end
          end
        end
      end

      # if in only 2 cols is there another box with same cand col ids
      if locked_cand_col_ids.length == 2
        other_box_ids = col.box_ids - [box.id]
        matched_box_id = other_box_ids.find do |other_box_id|
          other_box = board.boxes[other_box_id]
          cand_cells_other_box = other_box.cells_with_candidates([cand])
          locked_cand_col_ids == cand_cells_other_box.map(&:column_id).uniq
        end

        # if so, third box cant have the cand in those cols
        if matched_box_id
          third_box_id = (other_box_ids - [matched_box_id]).first
          third_box = board.boxes[third_box_id]

          third_box.cells_with_candidates([cand]).each do |third_box_cell|
            if locked_cand_col_ids.include?(third_box_cell.column_id)
              new_candidates = third_box_cell.candidates - [cand]
              if new_candidates != third_box_cell.candidates
                board.update_cell(
                  third_box_cell.id,
                  new_candidates,
                  {strategy: name, claiming_box_id: "Box-#{third_box.id}|Col-#{col.id}|#{cand}"}
                )
              end
            end
          end
        end
      end 
    end
  end
end
