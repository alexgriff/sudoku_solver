module Strategy
  class BaseStrategy
    attr_reader :name

    def self.name
      self.to_s.split('::').last.downcase.to_sym
    end

    def self.apply(board)
      board.unsolved_cell_ids.each do |id|
        execute(board, id)
      end
    end
  end
end
