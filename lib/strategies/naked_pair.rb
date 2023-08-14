class Strategy::NakedPair < Strategy::BaseStrategy
  extend Strategy::NakedSubsetN
  
  def self.apply(board)
    naked_subset_n(2, board)
  end
end
