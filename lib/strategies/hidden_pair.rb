class Strategy::HiddenPair < Strategy::BaseStrategy
  extend Strategy::HiddenSubsetN

  def self.execute(board, cell_id)
    hidden_subset_n(2, board, cell_id)
  end
end
