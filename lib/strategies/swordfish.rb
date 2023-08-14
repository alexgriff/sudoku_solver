class Strategy::Swordfish < Strategy::BaseStrategy
  extend Strategy::BasicFish

  def self.apply(board)
    basic_fish_n(3, board)
  end
end
