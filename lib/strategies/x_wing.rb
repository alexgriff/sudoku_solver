class Strategy::XWing < Strategy::BaseStrategy
  def self.execute(board, cell_id)
    cell = board.state.get_cell(cell_id)
    
    cell.candidates.each do |cand|    
      # Rows - get all cell_ids with cand in the row
      cell_ids_with_cand_in_row = board.state.get_cell(cell_id).row(board).cell_ids_with_any_of_candidates([cand])

      # if the cand is in exactly 2 cells in the row, is there another row with same cand in exactly the same 2 _cols_?
      if cell_ids_with_cand_in_row.length == 2
        col_ids_with_cand_for_cell_row = cell_ids_with_cand_in_row.map { |id| Cell.new(id: id).column_id }
        
        matched_row_ids = board.rows.map(&:id).select do |row_id|          
          col_ids_with_cand_for_cell_row == board.rows[row_id].cell_ids_with_any_of_candidates([cand]).map { |id| Cell.new(id: id).column_id }
        end
        match_row_cell_ids = matched_row_ids
        
        # if so, the cand can be eliminated from the cols in cells that don't intersect with the 'matched' rows
        if matched_row_ids.length == 2   
          intersecting_cell_ids = matched_row_ids.map do |row_id|
            board.rows[row_id].cell_ids_with_any_of_candidates([cand])
          end.flatten
          
          col_ids_with_cand_for_cell_row.each do |col_id|
            board.columns[col_id].cell_ids_with_any_of_candidates([cand]).reject do |col_cell_id|
              matched_row_ids.include?(Cell.new(id: col_cell_id).row_id)
            end.each do |col_cell_id|
              col_cell = board.state.get_cell(col_cell_id)
              new_candidates = col_cell.candidates - [cand]
              if new_candidates != col_cell.candidates
                board.state.register_change(
                  board,
                  col_cell.id,
                  new_candidates,
                  {strategy: name, x_wing_id: "Rows-#{matched_row_ids}|Cols-#{col_ids_with_cand_for_cell_row}|Locked-#{cand}"}
                )
              end
            end
          end
        end
      end

      # Cols - get all cell_ids with cand in the col
      cell_ids_with_cand_in_col = board.state.get_cell(cell_id).column(board).cell_ids_with_any_of_candidates([cand])
      # if the cand is in exactly 2 cells in the col, is there another col with same cand in exactly the same 2 _rows_?
      if cell_ids_with_cand_in_col.length == 2
        row_ids_with_cand_for_cell_col = cell_ids_with_cand_in_col.map { |id| Cell.new(id: id).row_id }
        
        matched_col_ids = board.columns.map(&:id).select do |col_id|          
          row_ids_with_cand_for_cell_col == board.columns[col_id].cell_ids_with_any_of_candidates([cand]).map { |id| Cell.new(id: id).column_id }
        end

        # if so, the cand can be eliminated from the rows in cells that don't intersect with the 'matched' cols
        if matched_col_ids.length == 2
          row_ids_with_cand_for_cell_col.each do |row_id|            
            board.rows[row_id].cell_ids_with_any_of_candidates([cand]).reject do |row_cell_id|
              matched_col_ids.include?(Cell.new(id: row_cell_id).column_id)
            end.each do |row_cell_id|
              row_cell = board.state.get_cell(row_cell_id)
              new_candidates = row_cell.candidates - [cand]
              if new_candidates != row_cell.candidates
                board.state.register_change(
                  board,
                  row_cell.id,
                  new_candidates,
                  {strategy: name, x_wing_id: "Cols-#{matched_col_ids}|Rows-#{row_ids_with_cand_for_cell_col}|Locked-#{cand}"}
                )
              end
            end
          end
        end
      end
    end
  end
end
