class Strategy::NakedPair < Strategy::BaseStrategy
  extend Strategy::NakedSubsetN
  
  def self.execute(board, cell_id)
    naked_subset_n(2, board, cell_id)
  end
end
