class Strategy::NakedTriple < Strategy::BaseStrategy
  extend Strategy::NakedGroupN

  def self.execute(board, cell_id)
    naked_group_n(3, board, cell_id)
  end
end
