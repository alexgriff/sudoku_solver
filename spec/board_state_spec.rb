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
        expect(state.get_cell(0).candidates).to eq([2,6,8])
        expect(state.get_cell(64).candidates).to eq([3,4,5,6,7])
        
        state.register_change(board, 1, [6])
        
        # now, other cell in the same house shouldn't have 6 as a candidate
        expect(state.get_cell(0).candidates).to eq([2,8])
        expect(state.get_cell(64).candidates).to eq([3,4,5,7])
      end

      it 'cascades to solve other naked singles' do
        state.register_change(board, 14, [6])
        expect(state.get_cell(12).value).to eq 3
        expect(state.get_cell(21).value).to eq 1
        expect(state.get_cell(17).value).to eq 8
        expect(state.get_cell(9).value).to eq 5
        expect(state.get_cell(75).value).to eq 4
      end

      it "marks the dispatched action with 'solves' when they solve the cell" do
        state.register_change(board, 14, [6])
        action = state.history.find(cell_id: 14, solves: true)
        expect(action).to be_truthy
      end

      it 'passes along the action opts to the action' do
        state.register_change(board, 14, [6], {foo: 'bar'})
        action = state.history.find(cell_id: 14, foo: 'bar')
        expect(action).to be_truthy
      end

      it 'marks cascading actions with cascade value indicating the cell id it cascaded from' do
        state.register_change(board, 14, [6], {foo: 'bar'})
        action = state.history.find(cell_id: 12, cascade: 14)
        expect(action).to be_truthy
      end
    end
  end
end