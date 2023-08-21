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
    
    try_it(board, board.empty_cells - [selected_cell], selected_cell)
    
    # after finding the correct value, undo all the guesswork
    # and put the state into a 'clean' state with only the one guessed cell filled in
    correct_value = selected_cell.value
    first_guess = board.state.history.guesses.find { |action| action.strategy_id == selected_cell.id }
    board.state.undo(first_guess)
    board.state.register_change(
      board,
      selected_cell,
      [correct_value],
      {strategy: name}
    )
  end

  def self.try_it(board, empty_cells, cell)
    debugging = false
    return true if board.state.is_solved?

    puts "\n[Cell #{cell.id}]" if debugging
    puts "already filled!" if cell.filled? if debugging
    return try_it(board, empty_cells.slice(1..), empty_cells.first) if cell.filled?
  
    puts "trying it for #{cell.id}" if debugging
    shuffled_cands = cell.candidates.dup.shuffle(random: random)
    cand = shuffled_cands.pop

    while cand && !board.state.is_solved?
      begin
        puts "\n[Cell #{cell.id}]" if debugging
        puts "    -- next cands #{shuffled_cands.inspect}" if debugging
        puts "    -- attempting cand #{cand}" if debugging
        board.state.register_change(
          board,
          cell,
          [cand],
          {strategy: name, strategy_id: cell.id}
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
        if board.state.is_solved?
          return true
        else
          it_worked = try_it(board, empty_cells.slice(1..), empty_cells.first) 
          if it_worked
            true
          else
            cand = shuffled_cands.pop
            next
          end
        end
      end
    end
    puts "\n[Cell #{cell.id}]" if debugging
    puts "no more candidates - will return #{board.state.is_solved?}" if debugging
    if board.state.is_solved?
      true
    else
      puts "******RESETTING STATE******" if debugging
      board.state.undo(board.state.history.guesses.last)
      false
    end
  end
end
