class Solve
  # Loosely following standard solve order from: https://hodoku.sourceforge.net/en/docs_solv.php#progress_1
  # (Full House, Naked Single, Hidden Single, Locked Pair, Naked Pair, Locked Candidates,
  # Locked Triple, Naked Triple, Naked Quadruple, Hidden Pair, X-Wing, Swordfish,
  # Simple Colors, Multi Colors, Hidden Triple, XY-Wing, Hidden Quadruple
  BASIC_STRATEGIES = [
    Strategy::HiddenSingle,
    Strategy::NakedPair,
    Strategy::LockedCandidatesPointing,
    Strategy::LockedCandidatesClaiming,
    Strategy::NakedTriple,
    Strategy::NakedQuadruple,
    Strategy::HiddenPair,
    Strategy::XWing,
    Strategy::Swordfish,
    Strategy::HiddenTriple,
    Strategy::YWing,
    Strategy::Skyscraper,
    # Strategy::SimpleColoring
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
      puts(Solve::Summary.new(board.state.history, strategies).summarize) if with_summary
      board.state.is_solved?
    else
      solve(board)
    end
  end
end
