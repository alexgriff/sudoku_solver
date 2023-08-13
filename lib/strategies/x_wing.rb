class Strategy::XWing < Strategy::BaseStrategy
  def self.execute(board, cell)
    cell.candidates.each do |cand|    
      # Rows - get all cell_ids with cand in the row
      cells_with_cand_in_row = cell.row(board).cells_with_any_of_candidates([cand])

      # if the cand is in exactly 2 cells in the row, is there another row with same cand in exactly the same 2 _cols_?
      if cells_with_cand_in_row.length == 2
        col_ids_with_cand_in_cell_row = cells_with_cand_in_row.map(&:column_id)
        
        matched_rows = board.rows.map.select do |row|
          col_ids_with_cand_in_cell_row == row.cells_with_any_of_candidates([cand]).map(&:column_id)
        end
        
        # if so, the cand can be eliminated from the cols in cells that don't intersect with the 'matched' rows
        if matched_rows.length == 2
          col_ids_with_cand_in_cell_row.each do |col_id|
            col = board.columns[col_id]
            col.cells_with_any_of_candidates([cand]).reject do |col_cell|
              matched_rows.map(&:id).include?(col_cell.row_id)
            end.each do |col_cell|
              board.state.register_change(
                board,
                col_cell,
                col_cell.candidates - [cand],
                {strategy: name, x_wing_id: "Rows-#{matched_rows.map(&:id)}|Cols-#{col_ids_with_cand_in_cell_row}|Locked-#{cand}"}
              )
            end
          end
        end
      end

      # Cols - get all cell_ids with cand in the col
      cells_with_cand_in_col = cell.column(board).cells_with_any_of_candidates([cand])
      # if the cand is in exactly 2 cells in the col, is there another col with same cand in exactly the same 2 _rows_?
      if cells_with_cand_in_col.length == 2
        row_ids_with_cand_in_cell_col = cells_with_cand_in_col.map(&:row_id)
        
        matched_cols = board.columns.select do |col|
          row_ids_with_cand_in_cell_col == col.cells_with_any_of_candidates([cand]).map(&:row_id)
        end

        # if so, the cand can be eliminated from the rows in cells that don't intersect with the 'matched' cols
        if matched_cols.length == 2
          row_ids_with_cand_in_cell_col.each do |row_id|
            row = board.rows[row_id]
            row.cells_with_any_of_candidates([cand]).reject do |row_cell|
              matched_cols.map(&:id).include?(row_cell.column_id)
            end.each do |row_cell|
              board.state.register_change(
                board,
                row_cell,
                row_cell.candidates - [cand],
                {strategy: name, x_wing_id: "Cols-#{matched_cols.map(&:id)}|Rows-#{row_ids_with_cand_in_cell_col}|Locked-#{cand}"}
              )
            end
          end
        end
      end
    end
  end
end
