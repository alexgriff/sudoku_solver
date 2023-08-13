describe Cell do
  describe '#row_id' do
    it 'returns the row id for a given cell id' do
      # choosing a few arbitray cases
      expect(Cell.new(2).row_id).to eq 0
      expect(Cell.new(15).row_id).to eq 1
      expect(Cell.new(18).row_id).to eq 2
      expect(Cell.new(32).row_id).to eq 3
    end
  end

  describe '#column_id' do
    it 'returns the col id for a given cell id' do
        # choosing a few arbitray cases
        expect(Cell.new(9).column_id).to eq 0
        expect(Cell.new(46).column_id).to eq 1
        expect(Cell.new(2).column_id).to eq 2
        expect(Cell.new(21).column_id).to eq 3
    end
  end
  
  describe '#box_id' do
    it 'returns the box id for a given cell id' do
        # choosing a few arbitray cases
        expect(Cell.new(18).box_id).to eq 0
        expect(Cell.new(3).box_id).to eq 1
        expect(Cell.new(15).box_id).to eq 2
        expect(Cell.new(37).box_id).to eq 3
    end
  end

  context 'delgating data to state' do
    it "doesn't hold on data but gets it from passed state" do
      class DummyState
        def get_cell_value(id)
          1
        end

        def get_cell_candidates(id)
          [2,3,4]
        end
      end
      cell = Cell.new(9)
      cell.use_state(DummyState.new)

      expect(cell.value).to eq(1)
      expect(cell.candidates).to eq([2,3,4])
    end
  end
end
