class Solve
  attr_reader :strategies

  def initialize(strategies = Strategy::BASIC)
    @strategies = strategies.map { |name| Strategy.new(name) }
  end
  
  def solve(board)    
    board.reducer.dispatch(Action.new(type: Action::NEW_PASS))
    
    strategies.each do |strategy|
      strategy.apply(board)
      
      fillable_cells = board.empty_cells.select(&:has_one_remaining_candidate?)
      # fill in as many fillable cells as you can before advancing
      while fillable_cells.any?
        fillable_cells.each do |cell|
          board.reducer.dispatch(
            Action.new(type: Action::FILL_CELL, id: cell.id, value: cell.candidates.last)
          )
        end
        fillable_cells = board.empty_cells.select(&:has_one_remaining_candidate?)
      end
    end

    if board.solved?
      true
    elsif board.touched?
      solve(board)
    else
      false # couldn't solve
    end
  end
end
