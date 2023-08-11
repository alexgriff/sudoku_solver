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

  let(:board_missing_two) do
    <<~SUDOKU
       8 9 4 | 5 1 2 | 3 6 7
       5 6 7 | 3 . . | 1 8 2
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

  it 'can solve taking into account rows and columns' do
    board = Board.from_txt(board_missing_two)
    Solve.new.solve(board)
    expect(board.state.is_solved?).to eq(true)
  end

  let(:board_missing_more) do
    <<~SUDOKU
       8 9 4 | . . . | 3 6 7
       5 6 7 | . . . | 1 8 2
       1 3 . | . . . | 4 9 5
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

  it "can solve taking into multiple 'passes'" do
    # TODO: this no longer does multiple passes since more strategies have been added
    board = Board.from_txt(board_missing_more)
    Solve.new.solve(board)
    expect(board.state.is_solved?).to eq(true)
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
      # debugger if boards[i].id == "148c632971e7351d85fb4b1d1cf7e42f964cf86d6faedc2248f5d05616d710ea"
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
  
  # it "can solve a series of expert sudokus" do
  #   boards = File.read("spec/fixtures/experts.txt").split("\n\n").map { |txt| Board.from_txt(txt) }
  #   solved = boards.map { |board| Solve.new.solve(board) }
  #   solved.each.with_index do |status, i|
  #     expect("#{i} - #{status}").to eq("#{i} - true")
  #   end
  # end

  # regression testing example - paste in new regression
  # let(:regression) do
  #   <<~SUDOKU
  #   . 3 . | . . . | . . .
  #   6 . . | . . 3 | 8 1 .
  #   9 2 . | 5 1 . | . . 3
  #  -------|-------|-------
  #   5 1 . | 6 7 . | . . .
  #   . . . | . 8 . | . . .
  #   . . . | . 3 4 | . 5 6
  #  -------|-------|-------
  #   8 . . | . 4 1 | . 3 9
  #   . 6 1 | 8 . . | . . 2
  #   . . . | . . . | . 8 .
  #   SUDOKU
  # end

  # it 'can solve the current sudoku' do
  #   board = Board.from_txt(regression)
  #   <<~STUCK
  #   1 3 . | 4 6 6 | . . .
  #   6 . . | . . 3 | 8 1 .
  #   9 2 . | 5 1 . | . . 3
  #  -------|-------|-------
  #   5 1 . | 6 7 . | . . 8
  #   . . 6 | . 8 5 | . . .
  #   . 8 . | . 3 4 | . 5 6
  #  -------|-------|-------
  #   8 . . | . 4 1 | 6 3 9
  #   3 6 1 | 8 . . | . . 2
  #   . . . | 3 . . | . 8 .
  #   STUCK

  #   Solve.new.solve(board)
  #   expect(board.state.is_solved?).to eq(true)
  # end
end





