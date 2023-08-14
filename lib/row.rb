class Row < House
  HOUSE_TYPE = :row

  def boxes
    cells.map { |cell| board.boxes[cell.box_id] }.uniq
  end
end
