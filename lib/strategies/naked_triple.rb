class Strategy::NakedTriple < Strategy::BaseStrategy
  extend Strategy::NakedSubsetN

  def self.apply(board)
    naked_subset_n(3, board)
  end
end
