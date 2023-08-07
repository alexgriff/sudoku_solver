describe Cell do
  context 'initialization' do
    it 'is initalized with 1-9 as candidate values when empty' do
      expect(Cell.new(id: 1).candidates).to eq((1..9).to_a)
    end

    it 'removes the candidate value when initialized with value' do
      expect(Cell.new(id: 1, value: 3).candidates).to eq([])
    end
  end

  describe '#row_id' do
    it 'returns the row id for a given cell id' do
      # choosing a few arbitray cases
      expect(Cell.new(id: 2).row_id).to eq 0
      expect(Cell.new(id: 15).row_id).to eq 1
      expect(Cell.new(id: 18).row_id).to eq 2
      expect(Cell.new(id: 32).row_id).to eq 3
    end
  end

  describe '#column_id' do
    it 'returns the col id for a given cell id' do
        # choosing a few arbitray cases
        expect(Cell.new(id: 9).column_id).to eq 0
        expect(Cell.new(id: 46).column_id).to eq 1
        expect(Cell.new(id: 2).column_id).to eq 2
        expect(Cell.new(id: 21).column_id).to eq 3
    end
  end
  
  describe '#box_id' do
    it 'returns the box id for a given cell id' do
        # choosing a few arbitray cases
        expect(Cell.new(id: 18).box_id).to eq 0
        expect(Cell.new(id: 3).box_id).to eq 1
        expect(Cell.new(id: 15).box_id).to eq 2
        expect(Cell.new(id: 37).box_id).to eq 3
    end
  end
end
