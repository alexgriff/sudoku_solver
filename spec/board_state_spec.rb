describe Board::State do
  describe '#register_change' do
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
    let(:state) { board.state }

    context 'when a cell is updated to a solved state' do
      it 'dispatches a series of action to update other seen cells' do
        expect(board.cells[0].candidates).to eq([2,6,8])
        expect(board.cells[64].candidates).to eq([3,4,5,6,7])
        
        state.register_change(board, board.cells[1], [6])
        
        # now, other cell in the same house shouldn't have 6 as a candidate
        expect(board.cells[0].candidates).to eq([2,8])
        expect(board.cells[64].candidates).to eq([3,4,5,7])
      end

      it 'cascades to solve other naked singles' do
        state.register_change(board, board.cells[14], [6])
        expect(board.cells[12].value).to eq 3
        expect(board.cells[21].value).to eq 1
        expect(board.cells[17].value).to eq 8
        expect(board.cells[9].value).to eq 5
        expect(board.cells[75].value).to eq 4
      end

      it "marks the dispatched action with 'solves' when they solve the cell" do
        state.register_change(board, board.cells[14], [6])
        action = state.history.find(cell_id: 14, solves: true)
        expect(action).to be_truthy
      end

      it 'passes along the action opts to the action' do
        state.register_change(board, board.cells[14], [6], {foo: 'bar'})
        action = state.history.find(cell_id: 14, foo: 'bar')
        expect(action).to be_truthy
      end

      it 'marks cascading actions with cascaded_from_id value indicating the action id it cascaded from' do
        state.register_change(board, board.cells[14], [6], {foo: 'bar'})
        action = state.history.find(cell_id: 12)
        expect(action.cascaded_from_id).to be_truthy
      end
    end

    it 'raises if the board is put into an invalid state' do
      expect {
        state.register_change(board, board.cells[0], [9])
      }.to raise_error(Board::State::InvalidError)
    end
  end

  describe '#reset_to' do
    let(:board) do
      txt = <<~SUDOKU
      3 9 . | 4 6 . | . . .
      . . 6 | . . 3 | 7 . .
      8 . . | . . . | . 6 .
     -------|-------|-------
      2 . . | . . 1 | . 5 .
      . 5 . | . 9 . | . 4 .
      . 8 . | 2 . . | . . 6
     -------|-------|-------
      . 4 . | . . . | . . 8
      . . 2 | 8 . . | 5 . .
      . . . | . 1 5 | . 7 4
      SUDOKU

      Board.from_txt(txt)
    end

    it 'resets the board state to an arbitrary point in time' do
      original_state = board.state.instance_variable_get(:@cells)
      Strategy::HiddenSingle.apply(board)

      state_after_first_strategy = board.state.instance_variable_get(:@cells)
      expect(original_state).not_to eq(state_after_first_strategy)

      Strategy::LockedCandidatesPointing.apply(board)

      state_after_second_strategy = board.state.instance_variable_get(:@cells)
      expect(state_after_first_strategy).not_to eq(state_after_second_strategy)
      point_in_time = board.state.history.all.last

      Strategy::NakedTriple.apply(board)

      state_after_thirs_strategy = board.state.instance_variable_get(:@cells)
      expect(state_after_second_strategy).not_to eq(state_after_thirs_strategy)

      board.state.reset_to(point_in_time)
      current_state = board.state.instance_variable_get(:@cells)
      expect(current_state).to eq(state_after_second_strategy)
    end
  end
end
