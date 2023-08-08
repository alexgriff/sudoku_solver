class Solve
  BASIC_STRATEGIES = [
    Strategy::NakedSingle,
    Strategy::HiddenSingle,
    Strategy::NakedPair,
    Strategy::LockedCandidatesPointing,
    Strategy::LockedCandidatesClaiming,
    Strategy::HiddenPair
  ]
  
  attr_reader :strategies, :display, :with_summary

  def initialize(strategies: BASIC_STRATEGIES, display: false, with_summary: false)
    @strategies = strategies
    @display = display
    @with_summary = with_summary
  end
  
  def solve(board)    
    board.reducer.dispatch(Action.new(type: Action::NEW_PASS))

    strategies.each do |strategy|
      strategy.apply(board)
    end

    if board.solved? || !board.touched?
      board.print if display
      puts(board.summary) if with_summary
      board.solved?
    else
      solve(board)
    end
  end
end
