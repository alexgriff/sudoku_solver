class House
  def self.for_cell(board, cell)
    board.send(house_method).find do |house|
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

  def cell_ids
    @cell_ids ||= (0..(Board::NUM_CELLS - 1)).to_a.select do |i|
      Cell.new(id: i).send(self.class.house_id_method) == id
    end
  end

  def empty_cell_ids
    cell_ids.select { |cell_id| board.get_cell(cell_id).empty? }
  end

  def empty_other_cell_ids(filtered_cell_ids)
    empty_cell_ids - filtered_cell_ids
  end

  def other_cell_ids(filtered_cell_ids)
    cell_ids - filtered_cell_ids
  end
  
  def cell_ids_with_candidates(cands)
    empty_cell_ids.select { |cell_id| (cands & board.get_cell(cell_id).candidates).length == cands.length }
  end

  def other_cell_ids_with_candidates(filtered_cell_ids, cands)
    other_cell_ids(filtered_cell_ids).select do |cell_id|
      cell_ids_with_candidates(cands).include?(cell_id)
    end
  end

  def any_other_cells_with_candidates?(filtered_cell_ids, cands)
    other_cell_ids_with_candidates(filtered_cell_ids, cands).length > 0
  end

  def uniq_candidates
    candidate_counts.select { |k, v| v == 1}.keys
  end
  
  def candidate_counts
    empty_cell_ids.map do |cell_id|
      board.get_cell(cell_id).candidates
    end.flatten.each_with_object({}) do |cand, counts|
      counts[cand] ||= 0
      counts[cand] += 1
    end
  end

  def valid?
    all_non_emptys_are_unique?
  end

  private

  def all_non_emptys_are_unique?
    filled_values = cell_ids.map { |id| board.get_cell(id).value }.reject { |v| v == Cell::EMPTY }
    valid = filled_values.length == filled_values.uniq.length
    unless valid
      errors << ("#{self.class::HOUSE_TYPE} #{id} does not have uniq values")
    end
    valid
  end
end
