class Solve
  BASIC_STRATEGIES = [
    Strategy::HiddenSingle,
    Strategy::NakedPair,
    Strategy::LockedCandidatesPointing,
    Strategy::LockedCandidatesClaiming,
    Strategy::HiddenPair,
    Strategy::NakedTriple,
    Strategy::NakedQuadruple,
    Strategy::HiddenTriple,
    Strategy::XWing,
    Strategy::Swordfish
  ]
  
  attr_reader :strategies, :with_display, :with_summary

  def initialize(strategies: BASIC_STRATEGIES, with_display: false, with_summary: false)
    @strategies = strategies
    @with_display = with_display
    @with_summary = with_summary
  end

  def solve(board)
    board.state.register_next_pass

    # on the first pass look for naked singles already present from the starting state,
    # subsequent strategies account for completing naked singles discovered after the strategy is applied
    Strategy::NakedSingle.apply(board) if board.state.current_pass == 1

    strategies.each do |strategy|
      strategy.apply(board)
    end

    if board.state.is_solved? || !board.state.has_been_touched?
      board.state.register_done

      puts(board.display) if with_display
      puts(Solve::Summary.new(board.state.history).summarize) if with_summary
      board.state.is_solved?
    else
      solve(board)
    end
  end
end
