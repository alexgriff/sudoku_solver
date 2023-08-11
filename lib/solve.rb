class Solve
  BASIC_STRATEGIES = [
    Strategy::NakedSingle,
    Strategy::HiddenSingle,
    Strategy::NakedPair,
    Strategy::LockedCandidatesPointing,
    Strategy::LockedCandidatesClaiming,
    Strategy::HiddenPair,
    Strategy::NakedTriple,
    Strategy::NakedQuadruple
  ]
  
  attr_reader :strategies, :with_display, :with_summary

  def initialize(strategies: BASIC_STRATEGIES, with_display: false, with_summary: false)
    @strategies = strategies
    @with_display = with_display
    @with_summary = with_summary
  end

  def solve(board)
    board.state.register_next_pass

    strategies.each do |strategy|
      strategy.apply(board)
    end

    if board.state.is_solved? || !board.state.has_been_touched?
      board.state.register_done

      puts(board.display) if with_display
      puts(board.summary) if with_summary
      board.state.is_solved?
    else
      solve(board)
    end
  end
end
