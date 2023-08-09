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

  attr_reader :state, :columns, :rows, :boxes, :errors

  def initialize(initial_data)
    @columns = (0..SIZE-1).to_a.map { |id| Column.new(id: id, board: self) }
    @rows = (0..SIZE-1).to_a.map { |id| Row.new(id: id, board: self)}
    @boxes = (0..SIZE-1).to_a.map { |id| Box.new(id: id, board: self) }
    @errors = []
    
    @reducer = Board::Reducer.new(self)
    @state = {}
    reducer.dispatch(Action.new(type: Action::INIT))
    
    reducer.dispatch(
      Action.new(
        type: Action::NEW_BOARD_SYNC,
        initial_data: initial_data.map { |char| char == Cell::EMPTY ? char : char.to_i }
      )
    )
  end

  def set_state(state)
    @state = state
    raise "Board is invalid: #{errors.join("\n")}" unless valid?
  end

  def update_cell(cell_id, candidates, action_opts={})
    cell = get_cell(cell_id)
    solving = cell.empty? && candidates.length == 1

    if solving
      reducer.dispatch(
        Action.new(
          type: Action::FILL_CELL,
          cell_id: cell_id,
          value: candidates.first,
          **action_opts
        )
      )
      all_seen_empty_cell_ids_with_candidates_for(cell_id, candidates).each do |seen_cell_id|
        # Because the board state can change from the previous iteration of this loop,
        # all cells empty when the loop started may not still be empty when the next iteration runs.
        # Although sending an 'empty' update action doesnt alter the board state,
        # as an optimization check if you should still send the next action.
        # As another optimization take no action when the 2 cells share no candidates in common

        seen_cell = get_cell(seen_cell_id)
        if seen_cell.empty? && (seen_cell.candidates & candidates).length > 0
          update_cell(
            seen_cell_id,
            seen_cell.candidates - candidates,
            action_opts.merge(cascade: cell.id)
          )
        end
      end
    else
      reducer.dispatch(
        Action.new(
          type: Action::UPDATE_CELL,
          cell_id: cell_id,
          values: candidates,
          **action_opts
        )
      )
    end
    true
  end

  def start_pass
    reducer.dispatch(Action.new(type: Action::NEW_PASS))
  end

  def cells
    (0..NUM_CELLS-1).to_a.map { |i| get_cell(i) }
  end

  def get_cell(cell_id)
    Cell.from_state(
      id: cell_id,
      state: {value: state[:solved][cell_id], candidates: state[:cells][cell_id] }
    )
  end

  def empty_cells
    cells.select(&:empty?)
  end

  def empty_cell_ids
    empty_cells.map(&:id)
  end

  def solved?
    cells.all? { |cell| cell.filled? }
  end

  def touched?
    state[:touched]
  end

  def houses_for_cell(cell)
    [
      Row.for_cell(self, cell),
      Column.for_cell(self, cell),
      Box.for_cell(self, cell),
    ]
  end

  def all_seen_cell_ids_for(cell_id)
    (houses_for_cell(get_cell(cell_id)).map do |house|
      house.cell_ids
    end.flatten) - [cell_id]
  end
  
  def all_seen_empty_cell_ids_for(cell_id)
    all_seen_cell_ids_for(cell_id).select do |id|
      get_cell(id).empty?
    end
  end

  def all_seen_empty_cell_ids_with_candidates_for(cell_id, cands)
    all_seen_cell_ids_for(cell_id).select do |id|
      seen_cell = get_cell(id)
      seen_cell.empty? && (seen_cell.candidates & cands).length > 0
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
    initial_data = history.find(type: Action::NEW_BOARD_SYNC).initial_data
    initial_filled_cell_count = initial_data.reject { |v| v == Cell::EMPTY }.length
    initial_filled_cell_count_msg = "Filled cells at start: #{initial_filled_cell_count}"

    initial_solveable_cell_count = history.where(type: Action::FILL_CELL, strategy: Strategy::NakedSingle.name).length
    # TODO: this needs to be updated to look for naked singles _before_ any other strategies only
    # and then list naked singles that happen on subsquent passes
    initial_solveable_cell_count_msg = "Cells initially solveable 'by sudoku': #{initial_solveable_cell_count}"

    # TODO: some of thise may have changed with other refactors - assess
    hidden_single_cell_count = history.where(type: Action::FILL_CELL, strategy: Strategy::HiddenSingle.name).length
    hidden_single_cell_count_msg = "Hidden singles: #{hidden_single_cell_count}"

    naked_pairs = history.where(
      strategy: Strategy::NakedPair.name,
      type: Action::UPDATE_CELL,
    ).map(&:pair).uniq.length
    naked_pairs_msg = "Naked pairs: #{naked_pairs}"

    solveable_after_naked_pair_cells_count = history.where(
      type: Action::FILL_CELL,
      strategy: Strategy::NakedPair.name
    ).length
    solveable_after_naked_pair_cells_count_msg = "Cells solveable 'by sudoku' after identifying naked pair: #{solveable_after_naked_pair_cells_count}"

    aligned_candidates_in_box = history.where(
      strategy: Strategy::LockedCandidatesPointing.name,
      type: Action::UPDATE_CELL,
    ).map(&:locked_alignment_id).uniq.length
    aligned_candidates_in_box_msg = "Lines with locked, aligned candidates in same box: #{aligned_candidates_in_box}"

    solveable_after_aligned_candidates_cells_count = history.where(
      type: Action::FILL_CELL,
      strategy: Strategy::LockedCandidatesPointing.name
    ).length
    solveable_after_aligned_candidates_cells_count_msg = "Cells solveable 'by sudoku' after identifying locked, aligned candidates: #{solveable_after_aligned_candidates_cells_count}"

    claiming_lines = history.where(
      strategy: Strategy::LockedCandidatesClaiming.name,
      type: Action::UPDATE_CELL,
    ).map(&:claiming_box_id).uniq.length
    claiming_lines_msg = "Lines with 'claimed' candidate from box intersecting 2 locked candidate lines: #{claiming_lines}"

    solveable_after_claiming_lines_cells_count = history.where(
      type: Action::FILL_CELL,
      strategy: Strategy::LockedCandidatesClaiming.name
    ).length
    solveable_after_claiming_lines_cells_count_msg = "Cells solveable 'by sudoku' after identifying 'claiming' line/box: #{solveable_after_claiming_lines_cells_count}"

    hidden_pairs = history.where(
      strategy: Strategy::HiddenPair.name,
      type: Action::UPDATE_CELL
    ).map(&:pair).uniq.length
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
  attr_reader :reducer
  attr_writer :errors
end
