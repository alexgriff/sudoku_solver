describe Solve do
  let(:board_missing_one) do
    <<~SUDOKU
       8 9 4 | 5 1 2 | 3 6 7
       5 6 7 | 3 . 9 | 1 8 2
       1 3 2 | 8 7 6 | 4 9 5
      -------|-------|-------
       7 4 5 | 2 9 3 | 6 1 8
       2 8 9 | 1 6 4 | 7 5 3
       3 1 6 | 7 8 5 | 9 2 4
      -------|-------|-------
       4 2 8 | 9 3 1 | 5 7 6
       6 5 1 | 4 2 7 | 8 3 9
       9 7 3 | 6 5 8 | 2 4 1
    SUDOKU
  end

  it 'can solve a single missing cell' do
    board = Board.from_txt(board_missing_one)
    Solve.new.solve(board)
    expect(board.state.is_solved?).to eq(true)
  end

  it 'can provide a summary of the solve' do
    # value of this spec is mostly just ensuring nothing in Solve::Summary is very broken
    # it doesnt spec that the summary is actually accurate
    board = Board.from_txt(board_missing_one)
    expect {
      Solve.new(with_summary: true).solve(board)
    }.to output(a_string_including("Solved: true"))
     .to_stdout
  end

  let(:board_missing_more) do
    <<~SUDOKU
    . . . | . . . | . . .
    5 6 . | . 1 . | . 3 9
    7 8 1 | . . . | 5 4 6
   -------|-------|-------
    . 4 . | . . . | . 9 .
    . 3 . | . 2 . | . 6 .
    6 . . | . 4 . | . . 1
   -------|-------|-------
    . . 2 | . 5 . | 4 . .
    . . . | 4 . 3 | . . .
    . 7 . | 2 . 1 | . 8 .
    SUDOKU
  end

  it "can solve using multiple passes" do
    board = Board.from_txt(board_missing_more)
    Solve.new(strategies: [Strategy::HiddenSingle]).solve(board)
    expect(board.state.is_solved?).to eq(true)
    expect(board.state.current_pass).to be > 1
  end

  # Sudokus at various difficulty levels generated by https://qqwing.com/generate.html
  it 'can solve a series of simple sudokus' do
    boards = File.read("spec/fixtures/simples.txt").split("\n\n").map { |txt| Board.from_txt(txt) }
    solved = boards.map { |board| Solve.new.solve(board) }
    solved.each.with_index do |status, i|
      expect("#{i} - #{status}").to eq("#{i} - true")
    end
  end

  it "can solve a series of easy sudokus" do
    boards = File.read("spec/fixtures/easys.txt").split("\n\n").map { |txt| Board.from_txt(txt) }
    solved = boards.map { |board| Solve.new.solve(board) }
    solved.each.with_index do |status, i|
      expect("#{i} - #{status}").to eq("#{i} - true")
    end
  end
  
  it "can solve a series of intermediate sudokus" do
    boards = File.read("spec/fixtures/intermediates.txt").split("\n\n").map { |txt| Board.from_txt(txt) }
    solved = boards.map { |board| Solve.new.solve(board) }
    solved.each.with_index do |status, i|
      expect("#{i} - #{status}").to eq("#{i} - true")
    end
  end
  
  it "can solve a series of expert sudokus", skip: true do
    boards = File.read("spec/fixtures/experts.txt").split("\n\n").map { |txt| Board.from_txt(txt) }
    solved = boards.map do |board|
      Solve.new(strategies: Solve::BASIC_STRATEGIES + [Strategy::RandomGuess]).solve(board)
    end
    solved.each.with_index do |status, i|
      # expect("#{i} - #{status}").to eq("#{i} - true")
      # puts "#{i} - #{status}"
    end
  end

  it "can solve a _large_ series of sudokus reasonably quickly", skip: true do
    # 500 random boards
    boards = File.read("spec/fixtures/speed_test.txt").split("\n\n").map { |txt| Board.from_txt(txt) }
    solved = boards.map do |board|
      Solve.new(strategies: Solve::BASIC_STRATEGIES + [Strategy::RandomGuess]).solve(board)
    end

    solved.each.with_index do |status, i|
      # expect("#{i} - #{status}").to eq("#{i} - true")
      # puts "#{i} - #{status}"
    end
  end

  # regression testing example - paste in new regression
#   let(:regression) do
#     <<~SUDOKU
#     . . 9 | . . 7 | . 6 .
#     5 . . | . 3 2 | 4 . .
#     . 4 . | 9 . . | . . 5
#    -------|-------|-------
#     4 7 . | . . . | 6 . .
#     . 6 . | . 2 . | . 1 .
#     . . 2 | . . . | . 5 4
#    -------|-------|-------
#     9 . . | . . 6 | . 7 .
#     . . 7 | 2 9 . | . . 6
#     . 2 . | 8 . . | 1 . .
#     SUDOKU
#   end

#   it 'can solve the current sudoku' do
#     board = Board.from_txt(regression)
#     Solve.new.solve(board)
#     expect(board.state.is_solved?).to eq(true)
#   end
end
