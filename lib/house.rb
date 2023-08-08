class House
  def self.for_cell(board, cell)
    @klass_cache ||= {}
    cache_key = "#{board.object_id}-#{cell.id}"
    @klass_cache[cache_key] = board.send(house_method).find do |house|
      house.id == cell.send(house_id_method)
    end
  end

  def self.house_method
    case self::HOUSE_TYPE
      when :row
        :rows
      when :column
        :columns
      when :box
        :boxes
    end
  end

  def self.house_id_method
    "#{self::HOUSE_TYPE}_id"
  end

  attr_reader :id, :board, :errors

  def initialize(id:, board:)
    @id = id
    @board = board
    @errors = []
  end

  def filled_values
    filled_cells.map { |cell| cell.value }
  end

  def cell_ids
    @cell_ids ||= (0..(Board::NUM_CELLS - 1)).to_a.select do |i|
      Cell.new(id: i).send(self.class.house_id_method) == id
    end
  end

  def cells
    cell_ids.map { |id| board.get_cell(id) }
  end
  
  def empty_cell_ids
    cell_ids.select { |cell_id| board.get_cell(cell_id).empty? }
  end

  def empty_cells
    empty_cell_ids.map { |cell_id| board.get_cell(cell_id) }
  end
  
  def empty_other_cells(filtered_out_cell_ids)
    (empty_cell_ids - filtered_out_cell_ids).map { |cell_id| board.get_cell(cell_id) } 
  end

  def filled_cells
    cells.select(&:filled?)
  end

  def other_cell_ids(filtered_out_cell_ids)
    cell_ids - filtered_out_cell_ids
  end

  def other_cells(filtered_out_cell_ids)
    other_cell_ids(filtered_out_cell_ids).map { |id| board.get_cell(id) } 
  end
  
  def cells_with_candidates(cands)
    empty_cells.select { |cell| (cands & cell.candidates).length == cands.length }
  end

  def other_cells_with_candidates(filtered_out_cell_ids, cands)
    other_cells(filtered_out_cell_ids).select do |cell|
      cells_with_candidates(cands).map(&:id).include?(cell.id)
    end
  end

  def any_other_cells_with_candidates?(filtered_out_cell_ids, cands)
    other_cells_with_candidates(filtered_out_cell_ids, cands).any?
  end

  def uniq_candidates
    candidate_counts.select { |k, v| v == 1}.keys
  end
  
  def candidate_counts
    empty_cells.map do |cell|
      cell.candidates
    end.flatten.each_with_object({}) do |cand, counts|
      counts[cand] ||= 0
      counts[cand] += 1
    end
  end

  def valid?
    has_9_cells? && all_non_emptys_are_unique?
  end

  private

  def has_9_cells?
    valid = cells.length == 9
    unless cells.length == 9
      errors << ("#{self.class::HOUSE_TYPE} #{id} does not have 9 cells")
    end
    valid
  end

  def all_non_emptys_are_unique?
    valid = filled_values.length == filled_values.uniq.length
    unless valid
      errors << ("#{self.class::HOUSE_TYPE} #{id} does not have uniq values")
    end
    valid
  end
end
