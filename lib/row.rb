class Row < House
  HOUSE_TYPE = :row

  def box_ids
    cell_ids.map { |cell_id| Cell.new(id: cell_id).box_id }.uniq
  end
end
