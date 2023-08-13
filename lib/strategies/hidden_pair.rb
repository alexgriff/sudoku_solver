class Strategy::HiddenPair < Strategy::BaseStrategy
  extend Strategy::HiddenSubsetN

  def self.execute(board, cell)
    hidden_subset_n(2, board, cell)
  end
end
