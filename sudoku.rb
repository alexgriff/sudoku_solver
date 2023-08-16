require_relative './environment.rb'
require 'slop'

strategy_selections = {
  1 => Strategy::HiddenSingle,
  2 => Strategy::NakedPair,
  3 => Strategy::LockedCandidatesPointing,
  4 => Strategy::LockedCandidatesClaiming,
  5 => Strategy::NakedTriple,
  6 => Strategy::NakedQuadruple,
  7 => Strategy::HiddenPair,
  8 => Strategy::XWing,
  9 => Strategy::Swordfish,
  10 => Strategy::HiddenTriple,
  11 => Strategy::YWing,
  12 => Strategy::Skyscraper
}

opts = Slop.parse do |o|
  o.string '-b', '--board', 'board text', required: true
  o.array '-i', '--include', 'strategies to include', delimiter: ',', default: []
  o.array '-e', '--exclude', 'strategies to exclude', delimiter: ',', default: []
  o.on '-h', '--help' do
    puts <<~HELP
      Tries to solve the given sudoko board passed to the -b (--board) flag
      
      Usage:
      ruby sudoku.rb -b 6..3.8..4..3...2......7....2.......63...9...7.48.6.32.....4......57.64..8.41.27.9

      By default all strategies are applied to the solve the board.
      To see a list of supported strategies use -s (--strategies):

      ruby sudoku.rb -s
      
      To exclude specific strategies from that list use the strategy id and the -e (--exclude) flag

      ruby sudoku.rb -e 7,11,12 -b 6..3.8..4..3...2......7....2.......63...9...7.48.6.32.....4......57.64..8.41.27.9

      To instead only use the passed set of strategies and no other use the -i (--include flag)

      ruby sudoku.rb -i 1,2,3,4 -b 6..3.8..4..3...2......7....2.......63...9...7.48.6.32.....4......57.64..8.41.27.9

    HELP
    
    exit
  end
  o.on '-s', '--strategies' do
    puts "The following strategies are supported:\n\n"
    puts strategy_selections.map { |k,v| "#{k.to_s.ljust(2)} - #{v.name.to_s.capitalize.gsub('_', ' ')}"}
    puts "\nuse the id shown here with the --include or --exclude flags"
    exit
  end
end

including = opts[:include].any?
excluding = opts[:exclude].any?
raise "cannot include and exclude strategies simultaneously" if including && excluding

strategies = strategy_selections.values

if including
  strategies = strategy_selections.slice(*opts[:include].map(&:to_i)).values
end

if excluding
  strategies = strategy_selections.except(*opts[:exclude].map(&:to_i)).values
end


board_txt = opts[:board]
board = Board.from_txt(board_txt)

Solve.new(
  strategies: strategies,
  with_display: true,
  with_summary: true
).solve(board)

# cant solve this one 
# ruby sudoku.rb -b 47.2..1...9...87....19.....2.....3..91..8..62..4.....7.....24....53...7...6..1.83


# needs a hidden pair to solve
# txt = <<~SUDOKU
#  1 . . | 6 . . | . . 9
#  . 9 2 | 4 7 . | . 5 .
#  . . . | . . 9 | . 7 .
# -------|-------|-------
#  . . 9 | . . . | . 3 8
#  . 1 . | . 3 . | . 2 .
#  5 3 . | . . . | 1 . .
# -------|-------|-------
#  . 5 . | 9 . . | . . .
#  . 2 . | . 4 5 | 8 6 .
#  8 . . | . . 1 | . . 4
# SUDOKU

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
