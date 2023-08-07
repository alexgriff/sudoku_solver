class Strategy
  NAKED_SINGLE = :naked_single
  HIDDEN_SINGLE = :hidden_single
  NAKED_PAIR = :naked_pair
  LOCKED_CANDIDATES_POINTING = :locked_candidates_pointing
  LOCKED_CANDIDATES_CLAIMING = :locked_candidates_claiming
  HIDDEN_PAIR = :hidden_pair
  # TODO: naked triple / quadruple
  # TODO: hidden triple / quadruple


  BASIC = [
    HIDDEN_SINGLE,
    NAKED_PAIR,
    LOCKED_CANDIDATES_POINTING,
    LOCKED_CANDIDATES_CLAIMING,
    HIDDEN_PAIR,
  ]

  attr_reader :name

  def initialize(name)
    @name = name
  end

  def apply(board)
    board.empty_cell_ids.each do |id|
      send(name, board, id)
    end
  end

  private

  def hidden_single(board, cell_id)
    cell = board.find_cell(cell_id)
    if cell.candidates.length > 1
    uniq_in_row = (cell.candidates & Row.for_cell(board, cell).uniq_candidates).first
      uniq_in_col = (cell.candidates & Column.for_cell(board, cell).uniq_candidates).first
      uniq_in_box = (cell.candidates & Box.for_cell(board, cell).uniq_candidates).first
    
      uniq_candidate = uniq_in_row || uniq_in_col || uniq_in_box
      
      if uniq_candidate
        board.reducer.dispatch(
          Action.new(
            type: Action::FILL_CELL,
            cell_id: cell_id,
            value: uniq_candidate,
            strategy: name
          )
        )
      end
    end
  end

  def naked_pair(board, cell_id)
    cell = board.find_cell(cell_id)
    if cell.candidates.length == 2
      naked_pair_cands = cell.candidates
      
      row = Row.for_cell(board, cell)
      col = Column.for_cell(board, cell)
      box = Box.for_cell(board, cell)
      
      houses_with_naked_pair = [row, col, box].select do |house|
        house.other_cells([cell_id]).any? do |other_cell|
          other_cell.candidates == naked_pair_cands
        end
      end

      houses_with_naked_pair.each do |house|
        non_naked_pair_cells = house.cells.reject { |c| c.candidates == naked_pair_cands }
        
        non_naked_pair_cells.each do |non_paired_cell|
          new_candidates = non_paired_cell.candidates - naked_pair_cands
          if new_candidates != non_paired_cell.candidates
            board.reducer.dispatch(
              Action.new(
                type: Action::UPDATE_CANDIDATES,
                cell_id: non_paired_cell.id,
                naked_pair_cell_id: cell.id,
                new_candidates: new_candidates,
                strategy: name
              )
            )
          end
        end
      end
    end
  end

  def locked_candidates_pointing(board, cell_id)
    cell = board.find_cell(cell_id)
    box = Box.for_cell(board, cell)
    potentially_aligned_cands = box.candidate_counts.select { |k, v| v == 2 || v == 3 }.keys
    potentially_aligned_cands_cell_has = cell.candidates & potentially_aligned_cands
    
    aligned_candidates = potentially_aligned_cands_cell_has.each_with_object({}) do |cand, cand_to_line|
      cells_with_cand = box.empty_cells.select { |cell| cell.has_candidate?(cand) }
      if cells_with_cand.all? { |cell| cell.row_id == cells_with_cand.first.row_id }
        cand_to_line[cand] = board.rows[cell.row_id]
      elsif cells_with_cand.all? { |cell| cell.column_id == cells_with_cand.first.column_id }
        cand_to_line[cand] = board.columns[cell.column_id]
      end
    end

    aligned_candidates.each do |candidate, line_house|
      cells_in_line_not_in_box = line_house.empty_cell_ids - box.cell_ids        
      cells_in_line_not_in_box.each do |outside_cell_id|
        outside_cell = board.find_cell(outside_cell_id)
        new_candidates = outside_cell.candidates - [candidate]
        
        if new_candidates != outside_cell.candidates
          board.reducer.dispatch(
            Action.new(
              type: Action::UPDATE_CANDIDATES,
              cell_id: outside_cell_id,
              new_candidates: new_candidates,
              strategy: name,
              locked_alignment_id: "Box-#{box.id}|#{line_house.class.to_s}-#{line_house.id}|#{candidate}"
            )
          )
        end
      end
    end
  end

  def locked_candidates_claiming(board, cell_id)
    cell = board.find_cell(cell_id)
    row = Row.for_cell(board, cell)
    col = Column.for_cell(board, cell)
    box = Box.for_cell(board, cell)

    # find candidate that is only in 2 rows/cols in box
    cell.candidates.each do |cand|
      cand_cells = box.cells_with_candidates([cand])
      cand_row_ids = cand_cells.map(&:row_id).uniq
      cand_col_ids = cand_cells.map(&:column_id).uniq
      
      # if in only 2 rows is there another box with same cand row ids
      if cand_row_ids.length == 2
        other_box_ids = row.box_ids - [box.id]
        matched_box_id = other_box_ids.find do |other_box_id|
          other_box = board.boxes[other_box_id]
          cand_cells_other_box = other_box.cells_with_candidates([cand])
          cand_row_ids == cand_cells_other_box.map(&:row_id).uniq
        end
        
        # if so, third box cant have the cand in those rows
        if matched_box_id
          third_box_id = (other_box_ids - [matched_box_id]).first
          third_box = board.boxes[third_box_id]

          third_box.cells_with_candidates([cand]).each do |third_box_cell|
            if cand_row_ids.include?(third_box_cell.row_id)
              board.reducer.dispatch(
                Action.new(
                  type: Action::UPDATE_CANDIDATES,
                  cell_id: third_box_cell.id,
                  new_candidates: third_box_cell.candidates - [cand],
                  strategy: name,
                  claiming_box_id: "Box-#{third_box.id}|Row-#{row.id}|#{cand}"
                )
              )
            end
          end
        end
      end

      # if in only 2 cols is there another box with same cand col ids
      if cand_col_ids.length == 2
        other_box_ids = col.box_ids - [box.id]
        matched_box_id = other_box_ids.find do |other_box_id|
          other_box = board.boxes[other_box_id]
          cand_cells_other_box = other_box.cells_with_candidates([cand])
          cand_col_ids == cand_cells_other_box.map(&:column_id).uniq
        end

        # if so, third box cant have the cand in those cols
        if matched_box_id
          third_box_id = (other_box_ids - [matched_box_id]).first
          third_box = board.boxes[third_box_id]

          third_box.cells_with_candidates([cand]).each do |third_box_cell|
            if cand_col_ids.include?(third_box_cell.column_id)
              board.reducer.dispatch(
                Action.new(
                  type: Action::UPDATE_CANDIDATES,
                  cell_id: third_box_cell.id,
                  new_candidates: third_box_cell.candidates - [cand],
                  strategy: name,
                  claiming_box_id: "Box-#{third_box.id}|Col-#{col.id}|#{cand}"
                )
              )
            end
          end
        end
      end 
    end
  end

  def hidden_pair(board, cell_id)
    cell = board.find_cell(cell_id)
    # are any 2 of my candidates found in one other cell only
    if cell.candidates.length >= 2
      row = Row.for_cell(board, cell)
      col = Column.for_cell(board, cell)
      box = Box.for_cell(board, cell)

      cell.candidate_permutations(2).each do |cand_pair|
        hidden_pair_cells = [row, col, box].each_with_object([]) do |house, res|
          paired_cell = house.other_cells_with_candidates([cell.id], cand_pair).find do |potential_paired_cell|
            potential_paired_cell.candidates.length > 2 &&
            house.other_cells_with_candidates([cell.id, potential_paired_cell.id], [cand_pair[0]]).length == 0 &&
            house.other_cells_with_candidates([cell.id, potential_paired_cell.id], [cand_pair[1]]).length == 0
          end
          res << paired_cell if paired_cell
          res
        end

        hidden_pair_cells.each do |paired_cell|
          board.reducer.dispatch(
            Action.new(
              type: Action::UPDATE_CANDIDATES,
              cell_id: paired_cell.id,
              new_candidates: cand_pair,
              paired_cell_id: cell.id,
              strategy: name
            )
          )
        end
      end
    end
  end
end
