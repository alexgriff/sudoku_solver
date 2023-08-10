describe Board::Reducer do   
  describe '.touched_reducer' do
    let(:touched_state_false) do
      {
        touched: false,
        cells: [[1,2,3], [1]]
      }
    end
    let(:touched_state_true) do
      {
        touched: true,
        cells: [[1,2,3], [1]]
      }
    end

    it 'is set to true when a cell action alters the state' do
      expect(
        Board::Reducer.touched_reducer(
          touched_state_false,
          Action.new(type: Action::UPDATE_CELL, cell_id: 0, values: [1,2])
        )
      ).to be(true)
    end

    it 'does not update the state if no change is made to the state' do
      expect(
        Board::Reducer.touched_reducer(
          touched_state_true,
          Action.new(type: Action::UPDATE_CELL, cell_id: 0, values: [1,2,3])
        )
      ).to be(true)
      
      expect(
        Board::Reducer.touched_reducer(
          touched_state_false,
          Action.new(type: Action::UPDATE_CELL, cell_id: 0, values: [1,2,3])
        )
      ).to be(false)
    end

    it 'does not update the state for an already solved cell' do
      # in the reducer cells state context, solved means length == 1
      expect(
        Board::Reducer.touched_reducer(
          touched_state_true,
          Action.new(type: Action::UPDATE_CELL, cell_id: 1, values: [4,5])
        )
      ).to be(true)
      
      expect(
        Board::Reducer.touched_reducer(
          touched_state_false,
          Action.new(type: Action::UPDATE_CELL, cell_id: 1, values: [4,5])
        )
      ).to be(false)
    end
   
    it 'a new pass resets the state' do
      expect(
        Board::Reducer.touched_reducer(
          touched_state_true,
          Action.new(type: Action::NEW_PASS)
        )
      ).to be(false)
    end
  end

  describe '.passes_reducer' do
    let(:passes_state) { 10 }

    it 'a new pass action updates passes' do
      expect(
        Board::Reducer.passes_reducer(
          passes_state,
          Action.new(type: Action::NEW_PASS)
        )
      ).to eq(11)
    end
  end

  describe '.cells_reducer' do
    let(:initial_state) { [[1,2,3,4,5,6,7,8,9], [1,2,3,4,5,6,7,8,9], [1,2,3,4,5,6,7,8,9]] }
    let(:one_solved_state) { [[1,4,5], [2], [1,7,8]] }

    it 'can sync to a board' do
      expect(
        Board::Reducer.cells_reducer(
          initial_state,
          Action.new(
            type: Action::NEW_BOARD_SYNC,
            initial_data: [1, ".", "."],
            seen_cell_ids_map: {0 => [1, 2], 1 => [0, 2], 2 => [0, 1]}
          )
        )
      ).to eq([[1], [2,3,4,5,6,7,8,9], [2,3,4,5,6,7,8,9]])
    end

    it 'updates a cell in response to an action' do
      expect(
        Board::Reducer.cells_reducer(
          initial_state,
          Action.new(
            type: Action::UPDATE_CELL,
            cell_id: 0,
            values: [1,6]
          )
        )
      ).to eq([[1,6], [1,2,3,4,5,6,7,8,9], [1,2,3,4,5,6,7,8,9]])
    end
    
    it 'does not update a cell in that is already solved' do
      expect(
        Board::Reducer.cells_reducer(
          [[1,4,5], [2], [1,7,8]],
          Action.new(
            type: Action::UPDATE_CELL,
            cell_id: 1,
            values: [2, 3] 
          )
        )
      ).to eq([[1,4,5], [2], [1,7,8]])
      
      expect(
        Board::Reducer.cells_reducer(
          [[1,4,5], [2], [1,7,8]],
          Action.new(
            type: Action::UPDATE_CELL,
            cell_id: 1,
            values: [] 
          )
        )
      ).to eq([[1,4,5], [2], [1,7,8]])
    end
  end

  describe '.solved_reducer' do
    # returns hash of cell_id => cell_value
    it 'marks all initially present cells as solved when syncing board' do
      expect(
        Board::Reducer.solved_reducer(
          {},
          Action.new(
            type: Action::NEW_BOARD_SYNC,
            initial_data: [4, ".", 1],
            seen_cell_ids_map: {0 => [1, 2], 1 => [0, 2], 2 => [0, 1]}
          )
        )
      ).to eq({0 => 4, 2 => 1})
    end
   
    it 'updates in response to UPDATE_CELL actions with a only' do
      expect(
        Board::Reducer.solved_reducer(
          {},
          Action.new(
            type: Action::UPDATE_CELL,
            cell_id: 10,
            values: [6],
            solves: true
          )
        )
      ).to eq({10 => 6})
      
      expect(
        Board::Reducer.solved_reducer(
          {},
          Action.new(
            type: Action::UPDATE_CELL,
            cell_id: 10,
            values: [6]
          )
        )
      ).to eq({})
    end
  end
end
