class Strategy::NakedQuadruple < Strategy::BaseStrategy
  extend Strategy::NakedSubsetN

  def self.apply(board)
    naked_subset_n(4, board)
  end
end
