class Strategy::NakedSingle < Strategy::BaseStrategy
  def self.execute(board, cell)
    if cell.empty?  && cell.candidates.length == 1
      board.state.register_change(board, cell, [cell.candidates.first], {strategy: name})
    end
  end
end
