class Strategy::XWing < Strategy::BaseStrategy
  extend Strategy::BasicFish

  def self.apply(board)
    basic_fish_n(2, board)
  end
end
