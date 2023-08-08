class Strategy::NakedSingle < Strategy::BaseStrategy
  def self.execute(board, cell_id)
    cell = board.get_cell(cell_id)
    
    if !board.state[:solved][cell_id]
      board.houses_for_cell(cell).each do |house|
        naked_value = cell.candidates & house.uniq_candidates
        if naked_value
          board.reducer.dispatch(
            Action.new(
              type: Action::UPDATE_CELL,
              cell_id: cell_id,
              strategy: name,
              possible_values: [cell.value]
            )
          )
        end
      end
    end
  end
end
