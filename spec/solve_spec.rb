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
    e2_cell = board.rows[1].cells[4]
    expect(e2_cell.value).to eq(4)
    expect(board.solved?).to eq(true)
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
    e2_cell = board.rows[1].cells[4]
    f2_cell = board.rows[1].cells[5]
    expect(e2_cell.value).to eq(4)
    expect(f2_cell.value).to eq(9)
    expect(board.solved?).to eq(true)
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
    board = Board.from_txt(board_missing_more)
    Solve.new.solve(board)
    d2_cell = board.rows[1].cells[3]
    e2_cell = board.rows[1].cells[4]
    f2_cell = board.rows[1].cells[5]
    expect(d2_cell.value).to eq(3)
    expect(e2_cell.value).to eq(4)
    expect(f2_cell.value).to eq(9)
    expect(board.solved?).to eq(true)
  end

  # Sudokus at various difficulty levels generated by https://qqwing.com/generate.html
  it 'can solve a series of simple sudokus' do
    boards = File.read('spec/fixtures/simples.txt').split("\n\n").map { |txt| Board.from_txt(txt) }
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
  #   7 9 . | . . 4 | . . 2 
  #   . . . | . . 6 | . . . 
  #   . . 3 | . . . | . . . 
  #  -------|-------|-------
  #   . 8 2 | . 3 1 | . . 9 
  #   . . . | . 9 . | 4 . . 
  #   . 1 . | 6 . . | . 8 7 
  #  -------|-------|-------
  #   . 3 . | . 1 . | . . . 
  #   . . . | 8 . . | . 7 4 
  #   . 6 . | . . . | 2 . . 
  #   SUDOKU
  # end

  # it 'can solve the current sudoku' do
  #   board = Board.from_txt(regression)
  #   <<~STUCK
  #   7 9 5 | 1 8 4 | . 3 2 
  #   5 2 5 | 1 5 6 | . 3 8 
  #   . 2 3 | 1 5 5 | . 9 8 
  #  -------|-------|-------
  #   4 8 2 | 7 3 1 | 5 5 9 
  #   3 7 6 | 5 9 8 | 4 2 1 
  #   5 1 9 | 6 4 2 | 3 8 7 
  #  -------|-------|-------
  #   9 3 8 | 2 1 7 | 6 6 5 
  #   1 5 1 | 8 6 9 | . 7 4 
  #   8 6 8 | 4 7 . | 2 1 5 
  #   STUCK

  #   # Solve.new.solve(board)
  #   # expect(board.solved?).to eq(true)
  # end
end





