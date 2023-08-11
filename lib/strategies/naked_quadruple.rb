class Strategy::NakedQuadruple < Strategy::BaseStrategy
  extend Strategy::NakedGroupN

  def self.execute(board, cell_id)
    naked_group_n(4, board, cell_id)
  end
end
