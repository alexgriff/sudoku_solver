describe Board do
  describe '.from_txt' do
    let(:txt) do
      <<~SUDOKU
         . 8 4 | . 5 . | 9 1 .
         5 . . | 8 9 . | . . 2
         . . 7 | . . 2 | 3 . .
        -------|-------|-------
         . . . | . . . | . . .
         8 5 3 | . . . | 4 . .
         . 2 1 | . . . | . . .
        -------|-------|-------
         . . . | . 8 7 | . . .
         1 4 . | 3 . 9 | . 7 .
         3 . . | . 4 . | 2 . .
      SUDOKU
    end

    it 'can generate rows columns and boxes from formatted string' do
      board = Board.from_txt(txt)
      expect(board.rows.map { |row| row.cells.map(&:value) }).to eq(
        [
          [Cell::EMPTY, 8, 4, Cell::EMPTY, 5, Cell::EMPTY, 9, 1, Cell::EMPTY],
          [5, Cell::EMPTY, Cell::EMPTY, 8, 9, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, 2],
          [Cell::EMPTY, Cell::EMPTY, 7, Cell::EMPTY, Cell::EMPTY, 2, 3, Cell::EMPTY, Cell::EMPTY],
          [Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY,
           Cell::EMPTY],
          [8, 5, 3, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, 4, Cell::EMPTY, Cell::EMPTY],
          [Cell::EMPTY, 2, 1, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY],
          [Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, 8, 7, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY],
          [1, 4, Cell::EMPTY, 3, Cell::EMPTY, 9, Cell::EMPTY, 7, Cell::EMPTY],
          [3, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, 4, Cell::EMPTY, 2, Cell::EMPTY, Cell::EMPTY]
        ]
      )

      expect(board.columns.map { |col| col.cells.map(&:value) }).to eq(
        [
          [Cell::EMPTY, 5, Cell::EMPTY, Cell::EMPTY, 8, Cell::EMPTY, Cell::EMPTY, 1, 3],
          [8, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, 5, 2, Cell::EMPTY, 4, Cell::EMPTY],
          [4, Cell::EMPTY, 7, Cell::EMPTY, 3, 1, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY],
          [Cell::EMPTY, 8, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, 3, Cell::EMPTY],
          [5, 9, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, 8, Cell::EMPTY, 4],
          [Cell::EMPTY, Cell::EMPTY, 2, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, 7, 9, Cell::EMPTY],
          [9, Cell::EMPTY, 3, Cell::EMPTY, 4, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, 2],
          [1, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, 7, Cell::EMPTY],
          [Cell::EMPTY, 2, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY]
        ]
      )

      expect(board.boxes.map { |box| box.cells.map(&:value) }).to eq(
        [
          [Cell::EMPTY, 8, 4, 5, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, 7],
          [Cell::EMPTY, 5, Cell::EMPTY, 8, 9, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, 2],
          [9, 1, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, 2, 3, Cell::EMPTY, Cell::EMPTY],
          [Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, 8, 5, 3, Cell::EMPTY, 2, 1],
          [Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY,
           Cell::EMPTY],
          [Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, 4, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY],
          [Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, 1, 4, Cell::EMPTY, 3, Cell::EMPTY, Cell::EMPTY],
          [Cell::EMPTY, 8, 7, 3, Cell::EMPTY, 9, Cell::EMPTY, 4, Cell::EMPTY],
          [Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, Cell::EMPTY, 7, Cell::EMPTY, 2, Cell::EMPTY, Cell::EMPTY]
        ]
      )
    end
  end

  context 'initializing a board' do
    let(:board) do
      txt = <<~SUDOKU
      5 . . | 8 . 2 | . . 7
      . . . | . . . | . . .
      . 2 7 | . 4 . | 9 8 .
     -------|-------|-------
      . . . | 7 5 6 | . . .
      . 6 . | 1 9 4 | . 5 .
      . 1 . | . . . | . 6 .
     -------|-------|-------
      . 9 2 | . 6 . | 3 4 .
      . . . | . . . | . . .
      . . 6 | 2 . 1 | 5 . .
      SUDOKU
      Board.from_txt(txt)
    end

    it 'correctly accounts for initial solved cells' do
      expect(board.cells[0].value).to eq(5)

      # no other cell that cell 0 can see should have 5 as a candidate
      seen_cell_ids = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 18, 19, 20, 27, 36, 45, 54, 63, 72]
      seen_cell_ids.each do |seen_cell_id|
        expect(board.cells[seen_cell_id].candidates).not_to include(5)
      end
    end

    it 'initially is not marked as touched' do
      expect(board.state.has_been_touched?).to be false
    end

    it 'initially is not marked as solved' do
      expect(board.state.is_solved?).to be false
    end
  end
end
