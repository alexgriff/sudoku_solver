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

  attr_reader :id, :board

  def initialize(id:, board:)
    @id = id
    @board = board
  end

  def filled_values
    filled_cells.map { |cell| cell.value }
  end

  def cell_ids
    @cell_ids ||= (0..80).to_a.select do |i|
      Cell.new(id: i).send(self.class.house_id_method) == id
    end
  end

  def cells
    cell_ids.map { |id| board.find_cell(id) }
  end

  def empty_cells
    cells.select(&:empty?)
  end

  def empty_cell_ids
    empty_cells.map(&:id)
  end

  def filled_cells
    cells.select(&:filled?)
  end

  def other_cells(filtered_cell_ids)
    (cell_ids - filtered_cell_ids).map { |id| board.find_cell(id) } 
  end

  def cells_with_candidates(cands)
    empty_cells.select { |cell| (cands & cell.candidates).length == cands.length }
  end

  def other_cells_with_candidates(filtered_cell_ids, cands)
    empty_cells.select do |cell|
      other_cells(filtered_cell_ids).include?(cell) &&
      cells_with_candidates(cands).include?(cell)
    end
  end

  def uniq_candidates
    candidate_counts.select { |k, v| v == 1}.keys
  end

  def candidate_counts
    empty_cells.map(&:candidates)
               .flatten
               .each_with_object({}) do |cand, counts|
                  counts[cand] ||= 0
                  counts[cand] += 1
               end
  end

  def valid?
    has_9_cells? && all_non_emptys_are_unique?
  end

  private

  def has_9_cells?
    cells.length == 9
  end

  def all_non_emptys_are_unique?
    filled_values.length == filled_values.uniq.length
  end
end
