class House
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

  def cells
    @cells ||= board.cells.select do |cell|
      cell.send(self.class.house_id_method) == id
    end
  end

  def cell_ids
    @cell_ids ||= cells.map(&:id)
  end

  def empty_cells
    cells.select(&:empty?)
  end

  def other_cells(filtered_cells)
    cells - filtered_cells
  end

  def empty_other_cells(filtered_cells)
    filtered_cells.select(&:empty)
  end
  
  def cells_with_any_of_candidates(cands)
    empty_cells.select { |cell| cell.has_any_of_candidates?(cands) }
  end

  def other_cells_with_any_of_candidates(filtered_cells, cands)
    cells_with_any_of_candidates(cands) - filtered_cells
  end

  def cells_with_all_of_candidates(cands)
    empty_cells.select { |cell| cell.has_all_of_candidates?(cands) }
  end

  def uniq_candidates
    candidate_counts.select { |k, v| v == 1}.keys
  end
  
  def candidate_counts
    empty_cells.map(&:candidates).flatten.each_with_object({}) do |cand, counts|
      counts[cand] ||= 0
      counts[cand] += 1
    end
  end

  def valid?
    @errors = []
    all_non_emptys_are_unique?
  end

  private

  def all_non_emptys_are_unique?
    filled_values = cells.map(&:value).reject { |v| v == Cell::EMPTY }
    valid = filled_values.length == filled_values.uniq.length
    unless valid
      errors << ("#{self.class::HOUSE_TYPE.capitalize} #{id} does not have uniq values")
    end
    valid
  end
end
