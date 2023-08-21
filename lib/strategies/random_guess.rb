class Strategy::RandomGuess < Strategy::BaseStrategy
  def self.set_seed(seed)
    @@random = Random.new(seed)
  end

  def self.random
    @@random ||= Random.new
  end
 
  def self.apply(board, cell=nil)
    selected_cell = cell || board.empty_cells.sample(random: random)
    return if !selected_cell&.empty?
    strategy_application_id = selected_cell.id

    try_it(board, selected_cell, strategy_application_id)
    # after finding the correct value, undo all the guesswork
    # and put the board into a 'clean' state with only the single guessed cell filled in
    correct_value = selected_cell.value
    first_guess = guesses(board, strategy_application_id).first
    board.state.undo(first_guess)
    board.state.register_change(
      board,
      selected_cell,
      [correct_value],
      {strategy: name}
    )
  end

  def self.try_it(board, cell, strategy_application_id)
    return true if board.state.is_solved? || cell.filled?

    shuffled_cands = cell.candidates.dup.shuffle(random: random)
    cand = shuffled_cands.pop

    while cand && cell.empty?
      begin
        board.state.register_change(
          board,
          cell,
          [cand],
          {strategy: name, strategy_application_id: strategy_application_id}
        )
      rescue Board::State::InvalidError
        board.state.undo(guesses(board, strategy_application_id).last)
        next
      else
        try_it(board, board.empty_cells.sample(random: random), strategy_application_id)
      ensure
        cand = shuffled_cands.pop
      end
    end

    # when we've gotten here we've either exited the loop above due to finding a valid value for the cell,
    # or we've exhausted all possible candidates.
    # In the sad path case, we want to undo not just the last guess, that would get us
    # back to this same state, but the last 2
    if cell.filled?
      true
    else
      board.state.undo(guesses(board, strategy_application_id).last(2).first)
      false
    end
  end

  def self.guesses(board, strategy_application_id)
    board.state
         .history
         .where(strategy: Strategy::RandomGuess.name, solves: true, strategy_application_id: strategy_application_id)
         .reject { |action| action.cascaded_from_id }
  end
end
