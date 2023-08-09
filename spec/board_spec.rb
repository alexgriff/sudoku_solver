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

  describe '#update_cell' do
    let(:board) do
      txt = <<~SUDOKU
      . . . | 5 . 7 | . . .
      . 1 9 | . 4 . | 2 7 .
      . . 3 | . . . | 9 . .
     -------|-------|-------
      . . 6 | . . . | 3 . .
      4 . . | 8 . 3 | . . 5
      . . 2 | . . . | 8 . .
     -------|-------|-------
      . . . | . 7 . | . . .
      . . . | 2 . 8 | . . .
      . 9 . | . 1 . | . 6 .
      SUDOKU

      Board.from_txt(txt)
    end
    context 'when a cell is updated to a solved state' do
      it 'dispatches a series of action to update other seen cells' do
        board.update_cell(14, [6])
        expect(board.boxes[1].cells.map(&:candidates).flatten.uniq).not_to include(6)
      end

      it 'cascades to solve other naked singles' do
        board.update_cell(14, [6])
        expect(board.get_cell(12).value).to eq 3
        expect(board.get_cell(21).value).to eq 1
        expect(board.get_cell(17).value).to eq 8
        expect(board.get_cell(9).value).to eq 5
        expect(board.get_cell(75).value).to eq 4
      end

      it 'passes along the action opts to the action' do
        board.update_cell(14, [6], {foo: 'bar'})
        action = board.history.find(cell_id: 14, foo: 'bar')
        expect(action).to be_truthy
      end

      it 'marks cascading actions with cascade flag' do
        board.update_cell(14, [6], {foo: 'bar'})
        action = board.history.find(cell_id: 75, cascade: true)
        expect(action).to be_truthy
      end
    end
  end
end
