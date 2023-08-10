describe Board::Reducer do 
  let(:board) do
    txt = <<~SUDOKU
    . . . | 5 . 7 | . . .
    . . . | . . . | . . .
    . . . | . . . | . . .
   -------|-------|-------
    . . . | . . . | . . .
    . . . | . . . | . . .
    . . . | . . . | . . .
   -------|-------|-------
    . . . | . . . | . . .
    . . . | . . . | . . .
    . . . | . . . | . . .
    SUDOKU

    Board.from_txt(txt)
  end
  
  describe 'touched_reducer' do
    it 'is false initially after cells are inited from board' do
      expect(board.state.has_been_touched?).to be false
    end

    it 'is set to true if any part of the cells state changes' do
      board.state.register_change(board, 4, [9])
      expect(board.state.has_been_touched?).to be true
    end

    it 'does not update the state if no change is made to the state' do
      board.state.register_change(board, 3, [5])
      expect(board.state.has_been_touched?).to be false
    end
   
    it 'is false when a new pass starts' do
      board.state.register_change(board, 4, [9])
      expect(board.state.has_been_touched?).to be true
      
      board.state.register_next_pass
      expect(board.state.has_been_touched?).to be false
    end

    it 'a noop action does not toggle touched back to false in the same pass' do
      board.state.register_next_pass
      board.state.register_change(board, 4, [9])
      board.state.register_change(board, 4, [9])
      expect(board.state.has_been_touched?).to be true
    end

    it 'trying to update an already solved cell does not count as a touch' do
      board.state.register_change(board, 3, [5,6,7])
      expect(board.state.has_been_touched?).to be false
    end
  end

  describe 'cells_reducer' do
    context 'UPDATE_CELL action' do
      it 'updates the representation of the cell in state in response to action' do
        board.state.register_change(board, 4, [9])
        expect(board.state.get_cell(4).value).to eq(9)
      end

      it 'cannot update an already solved cell' do
        board.state.register_change(board, 3, [5,6,7])
        expect(board.state.get_cell(3).value).to eq(5)

        board.state.register_change(board, 3, [])
        expect(board.state.get_cell(3).value).to eq(5)
      end
    end
  end
end
