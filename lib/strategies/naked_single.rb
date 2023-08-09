class Strategy::NakedSingle < Strategy::BaseStrategy
  def self.execute(board, cell_id)
    cell = board.get_cell(cell_id)
    if cell.empty?  && cell.candidates.length == 1
      board.state.register_change(cell_id, [cell.candidates.first], {strategy: name})
    end
  end
end
