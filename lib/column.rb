class Column < House
 HOUSE_TYPE = :column

  def box_ids
    cells.map { |cell| cell.box_id }.uniq
  end
end
