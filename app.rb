require_relative './environment.rb'

# needs a hidden pair to solve
txt = <<~SUDOKU
 1 . . | 6 . . | . . 9
 . 9 2 | 4 7 . | . 5 .
 . . . | . . 9 | . 7 .
-------|-------|-------
 . . 9 | . . . | . 3 8
 . 1 . | . 3 . | . 2 .
 5 3 . | . . . | 1 . .
-------|-------|-------
 . 5 . | 9 . . | . . .
 . 2 . | . 4 5 | 8 6 .
 8 . . | . . 1 | . . 4
SUDOKU

board = Board.from_txt(txt)

strategies = [
  Strategy::NakedSingle,
  Strategy::HiddenSingle,
  Strategy::NakedPair,
  Strategy::LockedCandidatesPointing,
  Strategy::LockedCandidatesClaiming,
  Strategy::HiddenPair,
  Strategy::NakedTriple,
]

Solve.new(
  strategies: strategies,
  with_display: true,
  with_summary: true
).solve(board)


# uses a hidden pair if you disable naked pairs
# txt = <<~SUDOKU
#  . 8 . | . 4 . | 5 . .
#  4 . . | . . 6 | . . 9
#  5 . . | 1 . . | . 7 .
# -------|-------|-------
#  . . . | . 1 . | . . 2
#  . 2 6 | . 3 4 | . 1 .
#  . . . | . 9 . | . . 4
# -------|-------|-------
#  2 . . | 3 . . | . 8 .
#  3 . . | . . 9 | . . 7
#  . 1 . | . 7 . | 2 . .
# SUDOKU

# expert - can't solve currently
# txt = <<~SUDOKU
#  . . . | 6 . 9 | . . .
#  . 4 . | . . . | . 7 .
#  9 . 7 | . . . | 2 . 1
# -------|-------|-------
#  . 6 . | . . . | . 2 .
#  . . 5 | 7 9 1 | 8 . .
#  . . 4 | 3 . 6 | 7 . .
# -------|-------|-------
#  5 . . | 4 . 8 | . . 2
#  . . . | . 6 . | . . .
#  3 . . | . . . | . . 8
# SUDOKU
