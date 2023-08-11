class Strategy::NakedQuadruple < Strategy::BaseStrategy
  extend Strategy::NakedSubsetN

  def self.execute(board, cell_id)
    naked_subset_n(4, board, cell_id)
  end
end
