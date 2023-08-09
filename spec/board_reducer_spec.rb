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
  let(:reducer) { board.send(:reducer) }
  
  describe 'touched_reducer' do
    it 'is false initially after cells are inited from board' do
      expect(board.state[:touched]).to be false
    end

    it 'is set to true if any part of the cells state changes' do
      reducer.dispatch(
        Action.new(
          type: Action::UPDATE_CELL,
          cell_id: 4,
          values: [9]
        )
      )
      expect(board.state[:touched]).to be true
    end

    it 'does not update the state if no change is made to the state' do
      reducer.dispatch(
        Action.new(
          type: Action::UPDATE_CELL,
          cell_id: 3,
          values: [5]
        )
      )
      expect(board.state[:touched]).to be false
    end
   
    it 'is false when a new pass starts' do
      reducer.dispatch(
        Action.new(
          type: Action::UPDATE_CELL,
          cell_id: 4,
          values: [9]
        )
      )
      expect(board.state[:touched]).to be true
      
      reducer.dispatch(
        Action.new(type: Action::NEW_PASS)
      )
      expect(board.state[:touched]).to be false
    end

    it 'a noop action does not toggle touched back to false in the same pass' do
      reducer.dispatch(
        Action.new(type: Action::NEW_PASS)
      )
      reducer.dispatch(
        Action.new(
          type: Action::UPDATE_CELL,
          cell_id: 4,
          values: [9]
        )
      )
      reducer.dispatch(
        Action.new(
          type: Action::UPDATE_CELL,
          cell_id: 4,
          values: [9]
        )
      )
      expect(board.state[:touched]).to be true
    end

    it 'trying to update an already solved cell does not count as a touch' do
      reducer.dispatch(
        Action.new(
          type: Action::UPDATE_CELL,
          cell_id: 3,
          values: [5,6,7]
        )
      )

      expect(board.state[:touched]).to be false
    end
  end

  describe 'cells_reducer' do
    context 'UPDATE_CELL action' do
      it 'updates the representation of the cell in state in response to action' do
        reducer.dispatch(
          Action.new(
            type: Action::UPDATE_CELL,
            cell_id: 4,
            values: [9]
          )
        )
        expect(board.state[:cells][4]).to eq([9])
      end

      it 'does not update any other cells than the action cell_id' do
        prev_state = board.state[:cells]
        reducer.dispatch(
          Action.new(
            type: Action::UPDATE_CELL,
            cell_id: 6,
            values: [1,2,3,4]
          )
        )
        prev_state.each.with_index do |cell,
          i|
          unless i == 6
            expect(cell).to eq(prev_state[i])
          end
        end
      end

      it 'cannot update an already solved cell' do
        reducer.dispatch(
          Action.new(
            type: Action::UPDATE_CELL,
            cell_id: 3,
            values: [5,6,7]
          )
        )

        expect(board.state[:cells][3]).to eq([5])

        reducer.dispatch(
          Action.new(
            type: Action::UPDATE_CELL,
            cell_id: 3,
            values: []
          )
        )
        expect(board.state[:cells][3]).to eq([5])
      end
    end
  end
end
