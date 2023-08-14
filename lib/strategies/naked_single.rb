class Strategy::NakedSingle < Strategy::BaseStrategy
  def self.apply(board)
    board.each_empty_cell do |cell|
      if cell.candidates.length == 1
        board.state.register_change(board, cell, [cell.candidates.first], {strategy: name})
      end
    end
  end
end
