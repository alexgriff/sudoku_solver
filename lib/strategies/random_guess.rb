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
    
    try_it(board, selected_cell)
    
    # after finding the correct value, undo all the guesswork
    # and put the board into a 'clean' state with only the single guessed cell filled in
    correct_value = selected_cell.value
    first_guess = board.state.history.guesses.find { |action| action.strategy_application_id == selected_cell.id }
    board.state.undo(first_guess)
    board.state.register_change(
      board,
      selected_cell,
      [correct_value],
      {strategy: name}
    )
  end

  def self.try_it(board, cell)
    debugging = false
    return true if board.state.is_solved?
    puts "\n[Cell #{cell.id}]" if debugging
    puts "    -- trying it for #{cell.id}" if debugging
    shuffled_cands = cell.candidates.dup.shuffle(random: random)
    cand = shuffled_cands.pop

    while cand && cell.empty?
      begin
        puts "\n[Cell #{cell.id}]" if debugging
        puts "    -- next cands #{shuffled_cands.inspect}" if debugging
        puts "    -- attempting cand #{cand}" if debugging
        board.state.register_change(
          board,
          cell,
          [cand],
          {strategy: name, strategy_application_id: cell.id}
        )
      rescue Board::State::InvalidError
        puts "    -- cand #{cand} failed" if debugging
        puts "******RESETTING STATE******" if debugging
        board.state.undo(board.state.history.guesses.last)
        cand = shuffled_cands.pop
        next 
      else
        puts "    -- cand #{cand} succeeded!" if debugging
        puts "    -- board is solved? #{board.state.is_solved?}" if debugging
        it_worked = try_it(board, board.empty_cells.sample(random: random))
        cand = shuffled_cands.pop unless it_worked
      end
    end
    puts "\n[Cell #{cell.id}]" if debugging
    puts "    -- no more candidates - will return false" if cell.empty? && debugging
    puts "    -- cell is already filled! - will return true" if cell.filled? && debugging
    if cell.filled?
      true
    else
      puts "******RESETTING STATE******" if debugging
      board.state.undo(board.state.history.guesses.last)
      false
    end
  end
end
