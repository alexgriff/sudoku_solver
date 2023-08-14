class Box < House
  HOUSE_TYPE = :box

  def rows
    cells.map { |cell| board.rows[cell.row_id] }.uniq
  end

  def columns
    cells.map { |cell| board.columns[cell.column_id] }.uniq
  end
end
