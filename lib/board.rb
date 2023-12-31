class Board
  include SmartEnumerators::BoardEnumerators
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

    raise ParseError unless (
      data.length == NUM_CELLS &&
      data.all? { |d| (Cell::ALL_CANDIDATES + [Cell::EMPTY]).include?(d) }
    )

    new(data)
  end

  attr_reader :boxes, :columns, :rows, :houses, :state, :errors, :id

  def initialize(initial_data)
    @id = Digest::SHA256.hexdigest(initial_data.to_s)
    @columns = (0..SIZE-1).to_a.map { |id| Column.new(id: id, board: self) }
    @rows = (0..SIZE-1).to_a.map { |id| Row.new(id: id, board: self)}
    @boxes = (0..SIZE-1).to_a.map { |id| Box.new(id: id, board: self) }
    @houses = columns + rows + boxes

    @errors = []

    @state = Board::State.new
    state.register_starting_state(
      initial_data.map { |char| char == Cell::EMPTY ? char : char.to_i },
      (0...initial_data.length).to_a.each_with_object({}) { |id, res| res[id] = cells_seen_by(cells[id]).map(&:id) }
    )
  end

  def cells
    @cells ||= (0..NUM_CELLS-1).to_a.map do |id| 
      Cell.new(id).tap do |cell|
        cell.use_state(@state)
      end
    end
  end

  def empty_cells
    cells.select { |cell| cell.empty? }
  end

  def cells_with_candidates(cands)
    empty_cells.select { |cell| cell.has_candidates?(cands) }
  end

  def houses_for(cell)
    [
      rows[cell.row_id],
      columns[cell.column_id],
      boxes[cell.box_id]
    ]
  end

  def cells_seen_by(cell)
    houses_for(cell).map { |house| house.cells }.flatten - [cell]
  end
  
  def empty_cells_seen_by(cell)
    cells_seen_by(cell).select { |seen_cell| seen_cell.empty? }
  end

  def valid?
    @errors = []

    rows.each do |row|
      @errors += row.errors unless row.valid?
    end
    columns.each do |col|
      @errors += col.errors unless col.valid?
    end
    boxes.each do |box|
      @errors += box.errors unless box.valid?
    end
    errors.empty?
  end

  def inspect
    # printing the whole state object is too annoying and unwieldy
    "#<#{self.class.name} @id=#{id}>"
  end

  # these print methods are ugly, but ¯\_(ツ)_/¯ , will get to eventually...
  def display
    board_as_text = []
    top_3 = rows.slice(0...3)
    top_3.each do |row|
      cell_values = row.cells.map(&:value)
      left_3 = cell_values.slice(0...3)
      center_3 = cell_values.slice(3...6)
      right_3 = cell_values.slice(6..-1)
      board_as_text.push(" #{left_3.join(' ')} | #{center_3.join(' ')} | #{right_3.join(' ')} ")
    end
    board_as_text.push('-------|-------|-------')
    middle_3 = rows.slice(3...6)
    middle_3.each do |row|
      cell_values = row.cells.map(&:value)
      left_3 = cell_values.slice(0...3)
      center_3 = cell_values.slice(3...6)
      right_3 = cell_values.slice(6..-1)
      board_as_text.push(" #{left_3.join(' ')} | #{center_3.join(' ')} | #{right_3.join(' ')} ")
    end
    board_as_text.push('-------|-------|-------')
    bottom_3 = rows.slice(6..-1)
    bottom_3.each do |row|
      cell_values = row.cells.map(&:value)
      left_3 = cell_values.slice(0...3)
      center_3 = cell_values.slice(3...6)
      right_3 = cell_values.slice(6..-1)
      board_as_text.push(" #{left_3.join(' ')} | #{center_3.join(' ')} | #{right_3.join(' ')} ")
    end
    "#{board_as_text.join("\n")}\n\n"
  end

  def debug_print
    top_3 = rows.slice(0...3)
    top_3.each do |row|
      cell_values = row.cells.map do |cell|
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
      cell_values = row.cells.map do |cell|
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
      cell_values = row.cells.map do |cell|
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

  class ParseError < StandardError; end
end
