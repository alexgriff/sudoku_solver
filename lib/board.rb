class Board
  READABILITY_CHARACTERS = [' ', '|', '-'].freeze
  SIZE = 9
  NUM_CELLS = SIZE * SIZE


  def self.from_txt(txt)
    board_str = txt.split("\n").map do |row|
      row.tr(READABILITY_CHARACTERS.join, '')
    end.join

    data = board_str.chars.map do |char|
      char == Cell::EMPTY ? char : char.to_i
    end

    new(data)
  end

  attr_reader :state, :history, :columns, :rows, :boxes, :errors

  def initialize(initial_data)
    @columns = (0..SIZE-1).to_a.map { |id| Column.new(id: id, board: self) }
    @rows = (0..SIZE-1).to_a.map { |id| Row.new(id: id, board: self)}
    @boxes = (0..SIZE-1).to_a.map { |id| Box.new(id: id, board: self) }

    @errors = []
    
    @history = Board::History.new
    @state = Board::State.new(self)
    state.register_starting_state(initial_data.map { |char| char == Cell::EMPTY ? char : char.to_i })
  end

  def empty_cell_ids
    (0..NUM_CELLS-1).to_a.select { |i| state.get_cell(i).empty? }
  end

  def houses_for_cell(cell)
    [
      Row.for_cell(self, cell),
      Column.for_cell(self, cell),
      Box.for_cell(self, cell),
    ]
  end

  def all_seen_cell_ids_for(cell_id)
    (houses_for_cell(Cell.new(id: cell_id)).map do |house|
      house.cell_ids
    end.flatten) - [cell_id]
  end
  
  def all_seen_empty_cell_ids_for(cell_id)
    all_seen_cell_ids_for(cell_id).select do |id|
      state.get_cell(id).empty?
    end
  end

  def all_seen_empty_cell_ids_with_candidates_for(cell_id, cands)
    all_seen_cell_ids_for(cell_id).select do |id|
      seen_cell = state.get_cell(id)
      seen_cell.empty? && seen_cell.has_any_of_candidates?(cands)
    end
  end

  def valid?
    errors.clear

    rows.each do |row|
      self.errors += row.errors unless row.valid?
    end
    columns.each do |col|
      self.errors += col.errors unless col.valid?
    end
    boxes.each do |box|
      self.errors += box.errors unless box.valid?
    end
    errors.empty?
  end

  def summary
    Summary.new(history).summarize
  end

  def inspect
    # printing the whole state object is too annoying and unwieldy
    "#<#{self.class.name}:0x#{object_id.to_s(16).rjust(16, '0')}>"
  end

  # these print methods are ugly, but ¯\_(ツ)_/¯
  def print
    top_3 = rows.slice(0...3)
    top_3.each do |row|
      cell_values = row.cell_ids.map { |id| state.get_cell(id).value }
      left_3 = cell_values.slice(0...3)
      center_3 = cell_values.slice(3...6)
      right_3 = cell_values.slice(6..-1)
      puts(" #{left_3.join(' ')} | #{center_3.join(' ')} | #{right_3.join(' ')} ")
    end
    puts('-------|-------|-------')
    middle_3 = rows.slice(3...6)
    middle_3.each do |row|
      cell_values = row.cell_ids.map { |id| state.get_cell(id).value }
      left_3 = cell_values.slice(0...3)
      center_3 = cell_values.slice(3...6)
      right_3 = cell_values.slice(6..-1)
      puts(" #{left_3.join(' ')} | #{center_3.join(' ')} | #{right_3.join(' ')} ")
    end
    puts('-------|-------|-------')
    bottom_3 = rows.slice(6..-1)
    bottom_3.each do |row|
      cell_values = row.cell_ids.map { |id| state.get_cell(id).value }
      left_3 = cell_values.slice(0...3)
      center_3 = cell_values.slice(3...6)
      right_3 = cell_values.slice(6..-1)
      puts(" #{left_3.join(' ')} | #{center_3.join(' ')} | #{right_3.join(' ')} ")
    end
    nil
  end

  def debug_print
    top_3 = rows.slice(0...3)
    top_3.each do |row|
      cell_values = row.cell_ids.map do |cell_id|
        cell = state.get_cell(cell_id)
        if cell.filled?
          "#{cell.id.to_s.ljust(2)}= #{cell.value}".ljust(18)
        else
          "#{cell.id.to_s.ljust(2)}=(#{cell.candidates.join(',')})".ljust(18)
        end
      end
      left_3 = cell_values.slice(0...3)
      center_3 = cell_values.slice(3...6)
      right_3 = cell_values.slice(6..-1)
      puts(" #{left_3.join(' ')} | #{center_3.join(' ')} | #{right_3.join(' ')} ")
    end
    puts('----------------------------------------------------------|----------------------------------------------------------|---------------------------------------------------------')
    middle_3 = rows.slice(3...6)
    middle_3.each do |row|
      cell_values = row.cell_ids.map do |cell_id|
        cell = state.get_cell(cell_id)
        if cell.filled?
          "#{cell.id}= #{cell.value}".ljust(18)
        else
          "#{cell.id}=(#{cell.candidates.join(',')})".ljust(18)
        end
      end
      left_3 = cell_values.slice(0...3)
      center_3 = cell_values.slice(3...6)
      right_3 = cell_values.slice(6..-1)
      puts(" #{left_3.join(' ')} | #{center_3.join(' ')} | #{right_3.join(' ')} ")
    end
    puts('----------------------------------------------------------|----------------------------------------------------------|---------------------------------------------------------')
    bottom_3 = rows.slice(6..-1)
    bottom_3.each do |row|
      cell_values = row.cell_ids.map do |cell_id|
        cell = state.get_cell(cell_id)
        if cell.filled?
          "#{cell.id}= #{cell.value}".ljust(18)
        else
          "#{cell.id}=(#{cell.candidates.join(',')})".ljust(18)
        end
      end
      left_3 = cell_values.slice(0...3)
      center_3 = cell_values.slice(3...6)
      right_3 = cell_values.slice(6..-1)
      puts(" #{left_3.join(' ')} | #{center_3.join(' ')} | #{right_3.join(' ')} ")
    end
    nil
  end

  private

  attr_writer :errors
end
