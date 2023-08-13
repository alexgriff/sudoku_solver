class Strategy::NakedQuadruple < Strategy::BaseStrategy
  extend Strategy::NakedSubsetN

  def self.execute(board, cell)
    naked_subset_n(4, board, cell)
  end
end
