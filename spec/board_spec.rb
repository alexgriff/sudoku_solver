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
end
