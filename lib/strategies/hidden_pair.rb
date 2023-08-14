class Strategy::HiddenPair < Strategy::BaseStrategy
  extend Strategy::HiddenSubsetN

  def self.apply(board)
    hidden_subset_n(2, board)
  end
end
