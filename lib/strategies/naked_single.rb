class Strategy::NakedSingle < Strategy::BaseStrategy
  def self.execute(board, cell_id)
    cell = Cell.from_state(id: cell_id, state: board.state[:cells2][cell_id])

    if cell.filled? && !board.state[:solved][cell_id]
      board.reducer.dispatch(
        Action.new(
          type: Action::FILL_CELL,
          cell_id: cell_id,
          value: cell.value,
          strategy: name
        )
      )
    end
  end
end
