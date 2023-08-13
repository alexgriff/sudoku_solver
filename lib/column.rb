class Column < House
 HOUSE_TYPE = :column

  def boxes
    cells.map { |cell|cell.box(board) }.uniq
  end
end
