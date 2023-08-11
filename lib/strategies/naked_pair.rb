class Strategy::NakedPair < Strategy::BaseStrategy
  extend Strategy::NakedGroupN
  
  def self.execute(board, cell_id)
    naked_group_n(2, board, cell_id)
  end
end
