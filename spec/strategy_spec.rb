describe Strategy do
  # some strategy examples taken from:
  # https://hodoku.sourceforge.net/en/techniques.php

  describe Strategy::HiddenSingle do
    let(:strategy) { Strategy::HiddenSingle }

    let(:board) do
      # https://hodoku.sourceforge.net/en/tech_singles.php#h1
      # 6 is uniq candidate in Box 1 / Row 2 / Col 3
      txt = <<~SUDOKU
      . 2 8 | . . 7 | . . . 
      . 1 6 | . 8 3 | . 7 .
      . . . | . 2 . | 8 5 1
     -------|-------|-------
      1 3 7 | 2 9 . | . . .
      . . . | 7 3 . | . . .
      . . . | . 4 6 | 3 . 7
     -------|-------|-------
      2 9 . | . 7 . | . . .
      . . . | 8 6 . | 1 4 .
      . . . | 3 . . | 7 . .
      SUDOKU
      Board.from_txt(txt)
    end

    it 'updates the cell with a hidden single' do
      expect(board.find_cell(21).candidates).to eq([4, 6, 9])

      strategy.apply(board)
      expect(board.find_cell(21).value).to eq(6)

      action = board.reducer.history.find(
        cell_id: 21,
        type: Action::FILL_CELL,
        strategy: Strategy::HiddenSingle.name
      )
      expect(action).to be_truthy
    end
  end
  
  describe Strategy::NakedPair do
    let(:strategy) { Strategy::NakedPair }

    let(:board) do
      # https://hodoku.sourceforge.net/en/tech_naked.php
      # Row 7 has a naked pair of (3, 9) in Cols 2 & 3,
      # eliminating 3 as a candidate from another cell in that row
      txt = <<~SUDOKU
      7 . . | 8 4 9 | . 3 . 
      9 2 8 | 1 3 5 | . . 6
      4 . . | 2 6 7 | . 8 9
     -------|-------|-------
      6 4 2 | 7 8 3 | 9 5 1 
      3 9 7 | 4 5 1 | 6 2 8
      8 1 5 | 6 9 2 | 3 . .
     -------|-------|-------
      2 . 4 | 5 1 6 | . 9 3 
      1 . . | . . 8 | . 6 .
      5 . . | . . 4 | . 1 .
      SUDOKU
      Board.from_txt(txt)
    end

    it 'updates the candiates of the cell that cant be one of the naked pair candidates' do
      expect(board.find_cell(64).candidates).to eq([3, 7])
      
      strategy.apply(board)
      expect(board.find_cell(64).candidates).to eq([7])

      action = board.reducer.history.find(
        cell_id: 64,
        type: Action::UPDATE_CANDIDATES,
        strategy: Strategy::NakedPair.name
      )
      expect(action).to be_truthy
    end
  end

  describe Strategy::LockedCandidatesPointing do
    let(:strategy) { Strategy::LockedCandidatesPointing }

    let(:board) do
      # https://hodoku.sourceforge.net/en/tech_intersections.php
      # Box 0, Row 2 locks 5 as a candidate,
      # eliminating 5 as a candidate in Row 2 in other Boxes 
      txt = <<~SUDOKU
      9 8 4 | . . . | . . . 
      . . 2 | 5 . . | . 4 .
      . . 1 | 9 . 4 | . . 2
     -------|-------|-------
      . . 6 | . 9 7 | 2 3 . 
      . . 3 | 6 . 2 | . . .
      2 . 9 | . 3 5 | 6 1 .
     -------|-------|-------
      1 9 5 | 7 6 8 | 4 2 3 
      4 2 7 | 3 5 1 | 8 6 9
      6 3 8 | . . 9 | 7 5 1
      SUDOKU
      Board.from_txt(txt)
    end

    it "updates the candidates of cells in the same aligned row/col that can't be the locked candidate" do
      expect(board.find_cell(24).candidates).to eq([3, 5])
      
      strategy.apply(board)
      expect(board.find_cell(24).candidates).to eq([3])

      action = board.reducer.history.find(
        cell_id: 24,
        type: Action::UPDATE_CANDIDATES,
        strategy: Strategy::LockedCandidatesPointing.name
      )
      expect(action).to be_truthy
    end
  end

  describe Strategy::LockedCandidatesClaiming do
    let(:strategy) { Strategy::LockedCandidatesClaiming }

    let(:board) do
      # https://hodoku.sourceforge.net/en/tech_intersections.php
      # Boxes 1 and 2 have 7 as a candidate in Rows 0 & 2, thus 7 in Box 1 must be in Row 1.
      # It can be eliminated as a candidate in Rows 0 & 2 for the box.
      txt = <<~SUDOKU
      3 1 8 | . . 5 | 4 . 6 
      . . . | 6 . 3 | 8 1 . 
      . . 6 | . 8 . | 5 . 3 
     -------|-------|-------
      8 6 4 | 9 5 2 | 1 3 7 
      1 2 3 | 4 7 6 | 9 5 8 
      7 9 5 | 3 1 8 | 2 6 4 
     -------|-------|-------
      . 3 . | 5 . . | 7 8 . 
      . . . | . . 7 | 3 . 5 
      . . . | . 3 9 | 6 4 1 
      SUDOKU
      Board.from_txt(txt)
    end

    it 'updates the candidates of the cells in the box that must have the candidate in the free row/col' do
      expect(board.find_cell(19).candidates).to eq([4, 7])
      
      strategy.apply(board)
      expect(board.find_cell(19).candidates).to eq([4])

      action = board.reducer.history.find(
        cell_id: 19,
        type: Action::UPDATE_CANDIDATES,
        strategy: Strategy::LockedCandidatesClaiming.name
      )
      expect(action).to be_truthy
    end
  end

  describe Strategy::HiddenPair do
    let(:strategy) { Strategy::HiddenPair }

    let(:board) do
      # https://hodoku.sourceforge.net/en/tech_hidden.php#h2
      # 1 & 9 are unique candidates in Col 8, (Rows 4 & 6),
      # but the cell in Row 4 has other candidates as well, which can be eliminated
      txt = <<~SUDOKU
      . 4 9 | 1 3 2 | . . .
      . 8 1 | 4 7 9 | . . .
      3 2 7 | 6 8 5 | 9 1 4
     -------|-------|-------
      . 9 6 | . 5 1 | 8 . .
      . 7 5 | . 2 8 | . . .
      . 3 8 | . 4 6 | . . 5
     -------|-------|-------
      8 5 3 | 2 6 7 | . . .
      7 1 2 | 8 9 4 | 5 6 3
      9 6 4 | 5 1 3 | . . .
      SUDOKU
      Board.from_txt(txt)
    end

    it 'updates the candidates of the cell that cant be one of the hidden pair candidates' do
      expect(board.find_cell(44).candidates).to eq([1, 6, 9])
      
      strategy.apply(board)
      expect(board.find_cell(44).candidates).to eq([1, 9])

      action = board.reducer.history.find(
        cell_id: 44,
        type: Action::UPDATE_CANDIDATES,
        strategy: Strategy::HiddenPair.name
      )
      expect(action).to be_truthy
    end
  end
end
