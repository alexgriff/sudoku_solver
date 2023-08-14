class Column < House
 HOUSE_TYPE = :column

  def boxes
    cells.map { |cell|board.boxes[cell.box_id] }.uniq
  end
end
