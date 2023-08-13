class Strategy::HiddenTriple < Strategy::BaseStrategy
  extend Strategy::HiddenSubsetN

  def self.execute(board, cell)
    hidden_subset_n(3, board, cell)
  end
end
