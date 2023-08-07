class Solve
  attr_reader :strategies, :display, :with_summary

  def initialize(strategies: Strategy::BASIC, display: false, with_summary: false)
    @strategies = strategies.map { |name| Strategy.new(name) }
    @display = display
    @with_summary = with_summary
  end
  
  def solve(board)    
    board.reducer.dispatch(Action.new(type: Action::NEW_PASS))
    fill_cells(board, Strategy::NAKED_SINGLE)

    strategies.each do |strategy|
      strategy.apply(board)
      fill_cells(board, strategy.name)
    end

    if board.solved? || !board.touched?
      board.print if display
      puts(board.summary) if with_summary
      board.solved?
    else
      solve(board)
    end
  end

  def fill_cells(board, strategy_name)
    fillable_cells = board.empty_cells.select(&:has_one_remaining_candidate?)

    while fillable_cells.any?
      fillable_cells.each do |cell|
        board.reducer.dispatch(
          Action.new(
            type: Action::FILL_CELL,
            cell_id: cell.id,
            value: cell.candidates.last,
            strategy: strategy_name
          )
        )
      end
      fillable_cells = board.empty_cells.select(&:has_one_remaining_candidate?)
    end
  end
end
