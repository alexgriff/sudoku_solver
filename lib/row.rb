class Row < House
  HOUSE_TYPE = :row

  def boxes
    cells.map { |cell| cell.box(board) }.uniq
  end
end
