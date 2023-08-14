class House
  include SmartEnumerators::HouseEnumerators

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

  def complete?
    cells.all?(&:filled?)
  end

  def candidates
    empty_cells.map(&:candidates).flatten.uniq
  end

  def empty_cells
    cells.select(&:empty?)
  end
  
  def cells_with_candidates(cands)
    empty_cells.select { |cell| cell.has_candidates?(cands) }
  end

  def has_candidates?(cands)
    cells_with_candidates(cands).any?
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
