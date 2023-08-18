describe Strategy do
  # most strategy examples taken from:
  # https://hodoku.sourceforge.net/en/techniques.php

  describe Strategy::NakedSingle do
    let(:board) do
      # Cell 14 (Box 1, Row 1, Col 5) has 6 as it's single candidate
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

    it 'solves the cell with a naked single' do
      expect(board.cells[14].candidates).to eq([6])
      Strategy::NakedSingle.apply(board)
      expect(board.cells[14].value).to eq(6)
      action = board.state.history.find(
        cell_id: 14,
        type: Action::UPDATE_CELL,
        strategy: Strategy::NakedSingle.name
      )
      expect(action).to be_truthy
    end
  end

  describe Strategy::HiddenSingle do
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
      expect(board.cells[21].candidates).to eq([4, 6, 9])

      Strategy::HiddenSingle.apply(board)
      expect(board.cells[21].value).to eq(6)
      action = board.state.history.find(
        cell_id: 21,
        type: Action::UPDATE_CELL,
        strategy: Strategy::HiddenSingle.name
      )
      expect(action).to be_truthy
    end
  end
  
  describe Strategy::NakedPair do
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
      expect(board.cells[64].candidates).to eq([3, 7])

      Strategy::NakedPair.apply(board)
      expect(board.cells[64].value).to eq(7)

      action = board.state.history.find(
        cell_id: 64,
        type: Action::UPDATE_CELL,
        strategy: Strategy::NakedPair.name,
      )
      expect(action).to be_truthy
    end
  end

  describe Strategy::LockedCandidatesPointing do
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
      expect(board.cells[24].candidates).to eq([3, 5])

      Strategy::LockedCandidatesPointing.apply(board)
      expect(board.cells[24].value).to eq(3)

      action = board.state.history.find(
        cell_id: 24,
        type: Action::UPDATE_CELL,
        strategy: Strategy::LockedCandidatesPointing.name
      )
      expect(action).to be_truthy
    end
  end

  describe Strategy::LockedCandidatesClaiming do
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
      expect(board.cells[19].candidates).to eq([4, 7])
      
      Strategy::LockedCandidatesClaiming.apply(board)
      expect(board.cells[19].value).to eq(4)
      action = board.state.history.find(
        cell_id: 19,
        type: Action::UPDATE_CELL,
        strategy: Strategy::LockedCandidatesClaiming.name
      )
      expect(action).to be_truthy
    end
  end

  describe Strategy::HiddenPair do
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
      expect(board.cells[44].candidates).to eq([1, 6, 9])
      Strategy::HiddenPair.apply(board)
      expect(board.cells[44].candidates).to eq([1, 9])

      action = board.state.history.find(
        cell_id: 44,
        type: Action::UPDATE_CELL,
        strategy: Strategy::HiddenPair.name
      )
      expect(action).to be_truthy
    end
  end

  describe Strategy::NakedTriple do
    let(:board) do
      # https://hodoku.sourceforge.net/en/tech_naked.php#n3
      txt = <<~SUDOKU
      . . . | 2 9 4 | 3 8 .
      . . . | 1 7 8 | 6 4 .
      4 8 . | 3 5 6 | 1 . .
     -------|-------|-------
      . . 4 | 8 3 7 | 5 . 1
      . . . | 4 1 5 | 7 . .
      5 . . | 6 2 9 | 8 3 4
     -------|-------|-------
      9 5 3 | 7 8 2 | 4 1 6
      1 2 6 | 5 4 3 | 9 7 8
      . 4 . | 9 6 1 | 2 5 3
      SUDOKU
      Board.from_txt(txt)
    end

    let(:board1) do
      # https://hodoku.sourceforge.net/en/tech_naked.php#n3
      txt = <<~SUDOKU
      3 9 . | . . . | 7 . .
      . . . | . . . | 6 5 .
      5 . 7 | . . . | 3 4 9
     -------|-------|-------
      . 4 9 | 3 8 . | 5 . 6
      6 . 1 | . 5 4 | 9 8 3
      8 5 3 | . . . | 4 . .
     -------|-------|-------
      9 . . | 8 . . | 1 3 4
      . . 2 | 9 4 . | 8 6 5
      4 . . | . . . | 2 9 7
      SUDOKU
      Board.from_txt(txt)
    end

    it 'updates the candidates of the cell that cant be one of the naked triple candidates' do
      expect(board.cells[1].candidates).to eq([1, 6, 7])

      Strategy::NakedTriple.apply(board)

      expect(board.cells[1].candidates).to eq([1, 7])

      action = board.state.history.find(
        cell_id: 1,
        type: Action::UPDATE_CELL,
        strategy: Strategy::NakedTriple.name,
        strategy_id: "Column 1|[10, 28, 37]"
      )
      expect(action).to be_truthy

      expect(board1.cells[3].candidates & [1,2,6]).not_to be_empty
      expect(board1.cells[5].candidates & [1,2,6]).not_to be_empty
      expect(board1.cells[12].candidates & [1,2,6]).not_to be_empty
      expect(board1.cells[13].candidates & [1,2,6]).not_to be_empty
      expect(board1.cells[14].candidates & [1,2,6]).not_to be_empty
      expect(board1.cells[23].candidates & [1,2,6]).not_to be_empty

      Strategy::NakedTriple.apply(board1)

      expect(board1.cells[3].candidates & [1,2,6]).to be_empty
      expect(board1.cells[5].candidates & [1,2,6]).to be_empty
      expect(board1.cells[12].candidates & [1,2,6]).to be_empty
      expect(board1.cells[13].candidates & [1,2,6]).to be_empty
      expect(board1.cells[14].candidates & [1,2,6]).to be_empty
      expect(board1.cells[23].candidates & [1,2,6]).to be_empty
    end
  end

  describe Strategy::NakedQuadruple do
    let(:board) do
      # https://hodoku.sourceforge.net/en/tech_naked.php#n4
      txt = <<~SUDOKU
       . 1 . | 7 2 . | 5 6 3
       . 5 6 | . 3 . | 2 4 7
       7 3 2 | 5 4 6 | 1 8 9
      -------|-------|-------
       6 9 3 | 2 8 7 | 4 1 5
       2 4 7 | 6 1 5 | 9 3 8
       5 8 1 | 3 9 4 | . . .
      -------|-------|-------
       . . . | . . 2 | . . .
       . . . | . . . | . . 1
       . . 5 | 8 7 . | . . .
      SUDOKU
      Board.from_txt(txt)
    end

    it 'updates the candidates of the cell that cant be one of the naked quad candidates' do
      expect(board.cells[69].candidates & [3,4,8,9]).not_to be_empty
      expect(board.cells[70].candidates & [3,4,8,9]).not_to be_empty

      Strategy::NakedQuadruple.apply(board)

      expect(board.cells[69].candidates & [3,4,8,9]).to be_empty
      expect(board.cells[70].candidates & [3,4,8,9]).to be_empty

      action = board.state.history.find(
        cell_id: 69,
        type: Action::UPDATE_CELL,
        strategy: Strategy::NakedQuadruple.name,
        strategy_id: "Row 7|[63, 65, 66, 68]"
      )
      expect(action).to be_truthy
    end
  end

  describe Strategy::HiddenTriple do
    let(:board) do
      # https://hodoku.sourceforge.net/en/tech_hidden.php#h3
      txt = <<~SUDOKU
      5 . . | 6 2 . | . 3 7
      . . 4 | 8 9 . | . . .
      . . . | . 5 . | . . .
     -------|-------|-------
      9 3 . | . . . | . . .
      . 2 . | . . . | 6 . 5
      7 . . | . . . | . . 3
     -------|-------|-------
      . . . | . . 9 | . . .
      . . . | . . . | 7 . .
      6 8 . | 5 7 . | . . 2
      SUDOKU
      Board.from_txt(txt)
    end

    it 'updates the candidates of the cell that cant be one of the hidden triple candidates' do
      expect(board.cells[32].candidates).to eq([1,2,4,5,6,7,8])
      expect(board.cells[50].candidates).to eq([1,2,4,5,6,8])
      expect(board.cells[68].candidates).to eq([1,2,3,4,6,8])

      Strategy::HiddenTriple.apply(board)

      expect(board.cells[32].candidates).to eq([2,5,6])
      expect(board.cells[50].candidates).to eq([2,5,6])
      expect(board.cells[68].candidates).to eq([2,6])

      action = board.state.history.find(
        cell_id: 32,
        type: Action::UPDATE_CELL,
        strategy: Strategy::HiddenTriple.name,
        strategy_id: "Column 5|[32, 50, 68]"
      )
      expect(action).to be_truthy
    end
  end

  describe Strategy::XWing do
    let(:board) do
      # https://hodoku.sourceforge.net/en/tech_fishb.php#bf2
      txt = <<~SUDOKU
      . 4 1 | 7 2 9 | . 3 .
      7 6 9 | . . 3 | 4 . 2
      . 3 2 | 6 4 . | 7 1 9
     -------|-------|-------
      4 . 3 | 9 . . | 1 7 .
      6 . 7 | . . 4 | 9 . 3
      1 9 5 | 3 7 . | . 2 4
     -------|-------|-------
      2 1 4 | 5 6 7 | 3 9 8
      3 7 6 | . 9 . | 5 4 1
      9 5 8 | 4 3 1 | 2 6 7
      SUDOKU
      Board.from_txt(txt)
    end

    it 'updates the candidates of the cell that are eliminated by the x-wing' do
    expect(board.cells[31].candidates).to eq([5,8])
      Strategy::XWing.apply(board)
      expect(board.cells[31].value).to eq(8)

      action = board.state.history.find(
        cell_id: 31,
        type: Action::UPDATE_CELL,
        strategy: Strategy::XWing.name,
      )
      expect(action).to be_truthy
    end
  end

  describe Strategy::Swordfish do
    let(:board) do
      # https://hodoku.sourceforge.net/en/tech_fishb.php#bf3
      txt = <<~SUDOKU
      1 . 8 | 5 . . | 2 3 4
      5 . . | 3 . 2 | 1 7 8
      . . . | 8 . . | 5 6 9
     -------|-------|-------
      8 . . | 6 . 5 | 7 9 3
      . . 5 | 9 . . | 4 8 1
      3 . . | . . 8 | 6 5 2
     -------|-------|-------
      9 8 . | 2 . 6 | 3 1 .
      . . . | . . . | 8 . .
      . . . | 7 8 . | 9 . .
      SUDOKU
      Board.from_txt(txt)
    end

    it 'eliminates candidates by a swordfish (like an x-wing but 3 lines not 2)' do
      expect(board.cells[19].candidates).to include(4)
      expect(board.cells[20].candidates).to include(4)
      expect(board.cells[22].candidates).to include(4)

      expect(board.cells[46].candidates).to include(4)
      expect(board.cells[47].candidates).to include(4)
      expect(board.cells[49].candidates).to include(4)

      expect(board.cells[64].candidates).to include(4)
      expect(board.cells[65].candidates).to include(4)
      expect(board.cells[67].candidates).to include(4)

      expect(board.cells[73].candidates).to include(4)
      expect(board.cells[74].candidates).to include(4)


      Strategy::Swordfish.apply(board)

      expect(board.cells[19].candidates).not_to include(4)
      expect(board.cells[20].candidates).not_to include(4)
      expect(board.cells[22].candidates).not_to include(4)

      expect(board.cells[46].candidates).not_to include(4)
      expect(board.cells[47].candidates).not_to include(4)
      expect(board.cells[49].candidates).not_to include(4)

      expect(board.cells[64].candidates).not_to include(4)
      expect(board.cells[65].candidates).not_to include(4)
      expect(board.cells[67].candidates).not_to include(4)

      expect(board.cells[73].candidates).not_to include(4)
      expect(board.cells[74].candidates).not_to include(4)

      action = board.state.history.find(
        cell_id: 19,
        type: Action::UPDATE_CELL,
        strategy: Strategy::Swordfish.name,
      )
      expect(action).to be_truthy
    end
  end

  describe Strategy::YWing do
    let(:board) do
      # https://hodoku.sourceforge.net/en/tech_wings.php#xy
      # pivot is cell 27 with cands 1,6
      # it sees cell 30 with cands 1,9
      # and 37 with cands 6,9
      # eliminating 9 as a cand from any cell that can see 30 & 37
      txt = <<~SUDOKU
      7 1 4 | . 6 . | 5 3 8
      8 . . | 4 5 3 | . . 7
      3 5 6 | 7 1 8 | 4 2 9
     -------|-------|-------
      . . . | . 2 4 | . 8 5
      4 . . | . . . | 3 . 2
      2 8 5 | 3 7 6 | 9 4 1
     -------|-------|-------
      9 7 8 | 6 3 1 | 2 5 4
      . . . | . . 7 | . . 6
      . . . | . . . | . . 3
      SUDOKU
      Board.from_txt(txt)
    end

    it 'the pivot cell eliminates candidates' do
      expect(board.cells[28].candidates).to include(9)
      expect(board.cells[29].candidates).to include(9)
      expect(board.cells[39].candidates).to include(9)
      expect(board.cells[40].candidates).to include(9)
      expect(board.cells[41].candidates).to include(9)

      Strategy::YWing.apply(board)

      expect(board.cells[28].candidates).not_to include(9)
      expect(board.cells[29].candidates).not_to include(9)
      expect(board.cells[39].candidates).not_to include(9)
      expect(board.cells[40].candidates).not_to include(9)
      expect(board.cells[41].candidates).not_to include(9)

      action = board.state.history.find(
        cell_id: 41,
        type: Action::UPDATE_CELL,
        strategy: Strategy::YWing.name,
        strategy_id: "27-30-37|9"
      )
      expect(action).to be_truthy
    end
  end

  describe Strategy::Skyscraper do
    let(:board) do
      # https://hodoku.sourceforge.net/en/tech_sdp.php#sk
      # cols 5 and 8 have 1 as a cand in 2 positions only
      # in one of those positions they share the same row (row 4),
      # thus one or the other must be the candidate.
      # that means one or the other of the non-aligned-in-row cands will be the cand,
      # thus anything that sees both will not be able to be the candidate
      txt = <<~SUDOKU
      6 9 7 | . . . | . . 2
      . . 1 | 9 7 2 | . 6 3
      . . 3 | . . 6 | 7 9 .
     -------|-------|-------
      9 1 2 | . . . | 6 . 7
      3 7 4 | 2 6 . | 9 5 .
      8 6 5 | 7 . 9 | . 2 4
     -------|-------|-------
      1 4 8 | 6 9 3 | 2 7 5
      7 . 9 | . 2 4 | . . 6
      . . 6 | 8 . 7 | . . 9
      SUDOKU
      Board.from_txt(txt)
    end

    it 'candidates are eliminated by skyscraper' do
      expect(board.cells[21].candidates).to include(1)
      expect(board.cells[22].candidates).to include(1)
      expect(board.cells[6].candidates).to include(1)
      expect(board.cells[7].candidates).to include(1)

      Strategy::Skyscraper.apply(board)

      expect(board.cells[21].candidates).not_to include(1)
      expect(board.cells[22].candidates).not_to include(1)
      expect(board.cells[6].candidates).not_to include(1)
      expect(board.cells[7].candidates).not_to include(1)

      action = board.state.history.find(
        cell_id: 7,
        type: Action::UPDATE_CELL,
        strategy: Strategy::Skyscraper.name,
        strategy_id: "41-44|1"
      )
      expect(action).to be_truthy
    end
  end

  describe Strategy::SimpleColoring do
    let(:board_same_color) do
      # https://www.thonky.com/sudoku/simple-coloring
      txt = <<~SUDOKU
      . 5 . | . . . | 2 . 8
      7 . . | . . 3 | 6 . 4
      4 . . | . . . | . . 1
     -------|-------|-------
      . . . | . 7 . | . 1 .
      2 . . | 5 . . | . . 6
      . 4 . | . 3 6 | 9 7 .
     -------|-------|-------
      8 . . | . . 5 | 1 6 9
      6 . . | . 1 . | 8 2 3
      3 . 1 | . 6 . | 5 4 7
      SUDOKU
      Board.from_txt(txt)
    end

    let(:board_opposite_colors) do
      # https://www.thonky.com/sudoku/simple-coloring
      txt = <<~SUDOKU
      8 . 3 | 9 5 . | 4 . 7
      6 . 4 | . 3 . | 5 . .
      7 . 5 | . 4 . | 2 3 .
     -------|-------|-------
      4 . 2 | . 9 3 | 1 7 .
      1 . 9 | . 2 . | 3 4 .
      3 5 7 | 1 . 4 | . 9 2
     -------|-------|-------
      . 3 . | 4 7 . | 9 . 1
      9 7 . | 3 1 5 | . 2 4
      . 4 1 | . . 9 | 7 . 3
      SUDOKU
      Board.from_txt(txt)
    end

    it 'can solve cells when the same color appears 2x in a house' do
      expect(board_same_color.cells[10].candidates).to include(1)
      expect(board_same_color.cells[45].candidates).to include(1)
      expect(board_same_color.cells[41].candidates).to include(1)

      Strategy::SimpleColoring.apply(board_same_color)

      expect(board_same_color.cells[10].value).to eq(1)
      expect(board_same_color.cells[45].value).to eq(1)
      expect(board_same_color.cells[41].value).to eq(1)

      action = board_same_color.state.history.find(
        cell_id: 10,
        type: Action::UPDATE_CELL,
        strategy: Strategy::SimpleColoring.name,
        strategy_id: "[10, 41, 45]|1"
      )

      expect(action).to be_truthy
    end

    it 'eliminates candidates by simple coloring when opposite colors are seen by same cell', skip: true do
      expect(board_opposite_colors.cells[59].candidates).to include(6)
      expect(board_opposite_colors.cells[79].candidates).to include(6)

      Strategy::SimpleColoring.apply(board_opposite_colors)

      expect(board_opposite_colors.cells[59].candidates).not_to include(6)
      expect(board_opposite_colors.cells[79].candidates).not_to include(6)

      action = board_opposite_colors.state.history.find(
        cell_id: 7,
        type: Action::UPDATE_CELL,
        strategy: Strategy::SimpleColoring.name,
        strategy_id: 6
      )
      expect(action).to be_truthy
    end
  end
end
