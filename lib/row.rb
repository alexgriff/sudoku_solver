class Row < House
  HOUSE_TYPE = :row

  def box_ids
    cells.map { |cell| cell.box_id }.uniq
  end
end
