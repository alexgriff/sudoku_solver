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

  attr_reader :cells, :state, :columns, :rows, :boxes, :reducer, :errors

  def initialize(initial_data)
    @columns = (0..SIZE-1).to_a.map { |id| Column.new(id: id, board: self) }
    @rows = (0..SIZE-1).to_a.map { |id| Row.new(id: id, board: self)}
    @boxes = (0..SIZE-1).to_a.map { |id| Box.new(id: id, board: self) }
    @errors = []
    
    @reducer = Board::Reducer.new(self)
    @state = {}
    reducer.dispatch(Action.new(type: Action::INIT))
    
    initial_data.each.with_index do |char, i|
      if char != Cell::EMPTY
        reducer.dispatch(
          Action.new(
            type: Action::FILL_CELL,
            cell_id: i,
            value: char.to_i,
            init_board: true
          )
        )
      end
    end
  end

  def set_state(state)
    @state = state

    raise "Board is invalid: #{errors.join("\n")}" unless valid?
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

  def valid?
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

  def history
    reducer.history
  end

def summary
    initial_filled_cell_count = history.where(init_board: true).length
    initial_filled_cell_count_msg = "Filled cells at start: #{initial_filled_cell_count}"

    initial_solveable_cell_count = history.where(strategy: :naked_single).length
    initial_solveable_cell_count_msg = "Cells initially solveable 'by sudoku': #{initial_solveable_cell_count}"

    hidden_single_cell_count = history.where(strategy: Strategy::HiddenSingle.name).length
    hidden_single_cell_count_msg = "Hidden singles: #{hidden_single_cell_count}"

    naked_pairs = history.where(
      strategy: Strategy::NakedPair.name,
      type: Action::UPDATE_CANDIDATES,
    ).map(&:naked_pair_cell_id).uniq.length
    naked_pairs_msg = "Naked pairs: #{naked_pairs}"

    solveable_after_naked_pair_cells_count = history.where(
      type: Action::FILL_CELL,
      strategy: Strategy::NakedPair.name
    ).length
    solveable_after_naked_pair_cells_count_msg = "Cells solveable 'by sudoku' after identifying naked pair: #{solveable_after_naked_pair_cells_count}"

    aligned_candidates_in_box = history.where(
      strategy: Strategy::LockedCandidatesPointing.name,
      type: Action::UPDATE_CANDIDATES,
    ).map(&:locked_alignment_id).uniq.length
    aligned_candidates_in_box_msg = "Lines with locked, aligned candidates in same box: #{aligned_candidates_in_box}"

    solveable_after_aligned_candidates_cells_count = history.where(
      type: Action::FILL_CELL,
      strategy: Strategy::LockedCandidatesPointing.name
    ).length
    solveable_after_aligned_candidates_cells_count_msg = "Cells solveable 'by sudoku' after identifying locked, aligned candidates: #{solveable_after_aligned_candidates_cells_count}"

    claiming_lines = history.where(
      strategy: Strategy::LockedCandidatesClaiming.name,
      type: Action::UPDATE_CANDIDATES,
    ).map(&:claiming_box_id).uniq.length
    claiming_lines_msg = "Lines with 'claimed' candidate from bpx intersecting 2 locked candidate lines: #{claiming_lines}"

    solveable_after_claiming_lines_cells_count = history.where(
      type: Action::FILL_CELL,
      strategy: Strategy::LockedCandidatesClaiming.name
    ).length
    solveable_after_claiming_lines_cells_count_msg = "Cells solveable 'by sudoku' after identifying 'claiming' line/box: #{solveable_after_claiming_lines_cells_count}"

    hidden_pairs = history.where(
      strategy: Strategy::HiddenPair.name,
      type: Action::UPDATE_CANDIDATES
    ).map(&:paired_cell_id).uniq.length
    hidden_pairs_msg = "Hidden pairs: #{hidden_pairs}"

    total_count = (
      initial_filled_cell_count +
      initial_solveable_cell_count +
      hidden_single_cell_count +
      solveable_after_naked_pair_cells_count +
      solveable_after_aligned_candidates_cells_count +
      solveable_after_claiming_lines_cells_count
    )

    [
      "\n",
      "Solved: #{solved?}",
      initial_filled_cell_count_msg,
      initial_solveable_cell_count_msg,
      hidden_single_cell_count_msg,
      naked_pairs_msg,
      solveable_after_naked_pair_cells_count_msg,
      aligned_candidates_in_box_msg,
      solveable_after_aligned_candidates_cells_count_msg,
      claiming_lines_msg,
      solveable_after_claiming_lines_cells_count_msg,
      hidden_pairs_msg,
      "Passes: #{state[:passes]}",
      total_count
    ].join("\n")
  end

  private

  attr_writer :errors
end
