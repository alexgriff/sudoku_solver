require_relative './environment.rb'

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
  Strategy::HIDDEN_SINGLE,
  Strategy::NAKED_PAIR,
  Strategy::LOCKED_CANDIDATES_POINTING,
  Strategy::LOCKED_CANDIDATES_CLAIMING,
  # Strategy::HIDDEN_PAIR,
]

Solve.new(
  strategies: strategies,
  display: true,
  with_summary: true
).solve(board)





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
