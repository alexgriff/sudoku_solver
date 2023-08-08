class Strategy::HiddenSingle < Strategy::BaseStrategy
  def self.execute(board, cell_id)
    cell = Cell.from_state(id: cell_id, state: board.state[:cells2][cell_id])

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
end
