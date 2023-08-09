class Solve
  BASIC_STRATEGIES = [
    Strategy::NakedSingle,
    Strategy::HiddenSingle,
    Strategy::NakedPair,
    Strategy::LockedCandidatesPointing,
    Strategy::LockedCandidatesClaiming,
    Strategy::HiddenPair
  ]
  
  attr_reader :strategies, :with_display, :with_summary

  def initialize(strategies: BASIC_STRATEGIES, with_display: false, with_summary: false)
    @strategies = strategies
    @with_display = with_display
    @with_summary = with_summary
  end
  
  def solve(board)    
    board.register_next_pass

    strategies.each do |strategy|
      strategy.apply(board)
    end

    if board.solved? || !board.touched?
      board.register_done

      board.print if with_display
      puts(board.summary) if with_summary
      board.solved?
    else
      solve(board)
    end
  end
end
