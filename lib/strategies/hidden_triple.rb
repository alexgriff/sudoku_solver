class Strategy::HiddenTriple < Strategy::BaseStrategy
  extend Strategy::HiddenSubsetN

  def self.apply(board)
    hidden_subset_n(3, board)
  end
end
