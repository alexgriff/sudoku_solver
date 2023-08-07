class Board
  READABILITY_CHARACTERS = [' ', '|', '-'].freeze

  def self.from_txt(txt)
    board_str = txt.split("\n").map do |row|
      row.tr(READABILITY_CHARACTERS.join, '')
    end.join

    data = board_str.chars.map do |char|
      char == Cell::EMPTY ? char : char.to_i
    end

    new(data)
  end

  attr_reader :cells, :state, :columns, :rows, :boxes, :reducer
  attr_writer :state

  def initialize(initial_data)
    @columns = (0..8).to_a.map { |id| Column.new(id: id, board: self) }
    @rows = (0..8).to_a.map { |id| Row.new(id: id, board: self)}
    @boxes = (0..8).to_a.map { |id| Box.new(id: id, board: self) }
    
    @state = { 
      touched: false,
      passes: 0,
      cells: initial_data.map.with_index { |_char, i| Cell.new(id: i) }
    }

    @reducer = Board::Reducer.new(self)
    
    initial_data.each.with_index do |char, i|
      if char != Cell::EMPTY
        reducer.dispatch(
          Action.new(
            type: Action::FILL_CELL,
            id: i,
            value: char.to_i,
            initial: true
          )
        )
      end
    end
  end

  def empty_cells
    state[:cells].select(&:empty?)
  end

  def empty_cell_ids
    empty_cells.map(&:id)
  end

  def solved?
    state[:cells].all?(&:filled?)
  end

  def touched?
    state[:touched]
  end

  def find_cell(cell_id)
    state[:cells][cell_id]
  end

  def print
    top_3 = rows.slice(0...3)
    top_3.each do |row|
      cell_values = row.cells.map(&:value)
      left_3 = cell_values.slice(0...3)
      center_3 = cell_values.slice(3...6)
      right_3 = cell_values.slice(6..-1)
      puts(" #{left_3.join(' ')} | #{center_3.join(' ')} | #{right_3.join(' ')} ")
    end
    puts('-------|-------|-------')
    middle_3 = rows.slice(3...6)
    middle_3.each do |row|
      cell_values = row.cells.map(&:value)
      left_3 = cell_values.slice(0...3)
      center_3 = cell_values.slice(3...6)
      right_3 = cell_values.slice(6..-1)
      puts(" #{left_3.join(' ')} | #{center_3.join(' ')} | #{right_3.join(' ')} ")
    end
    puts('-------|-------|-------')
    bottom_3 = rows.slice(6..-1)
    bottom_3.each do |row|
      cell_values = row.cells.map(&:value)
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

  def inspect
    "#<#{self.class.name}:0x#{object_id.to_s(16).rjust(16, '0')}>"
  end

  def valid?
    # hacky thing for dev - incorporate in better way
    msg = ''
    rows.each do |row|
      msg += "Row #{row.id} is invalid\n" unless row.valid? 
    end
    columns.each do |col|
      msg += "Column #{col.id} is invalid\n" unless col.valid? 
    end
    boxes.each do |box|
      msg += "Box #{box.id} is invalid\n" unless box.valid? 
    end

    if msg.empty?
      true
    else
      puts msg
    end
  end
end
