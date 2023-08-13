class Strategy::NakedPair < Strategy::BaseStrategy
  extend Strategy::NakedSubsetN
  
  def self.execute(board, cell)
    naked_subset_n(2, board, cell)
  end
end
