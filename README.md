# Sudoku Solver
A Ruby program that solves sudokus.

## Instructions
Currently there's not a real CLI interface, so to interact with the program you can edit `cli.rb` \:shrug\:.

`bundle install` and run `ruby cli.rb`.

Sudoku boards generated from [https://qqwing.com/generate.html](https://qqwing.com/generate.html) can be copied pasted into this program. Currently the program should be able to solve any 'Simple', 'Easy', or 'Intermediate' boards and only vey rarely will be able to solve an 'Expert' board. More solving strategies will need to be supported! These board strings looks like
```rb
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
```
Although parsing boards from strings is fairly flexible and the program can also accept strings in a format like:
```rb
"1..6....9.9247..5......9.7...9....38.1..3..2.53....1...5.9......2..4586.8....1..4"
```
and possibly other copy-pasteable formats.

You can choose to output a summary of the solve to stdout by passing the `with_summary` flag to an instance of the `Solve` class, as well as diplay the solved board using `with_display`, ie
```rb
Solve.new(with_summary: true, with_display: true).solve(board)
```

### Strategies
Each "solve" can be passed the set of strategies you want to apply to the board. A lot of information about strategies and techniques can be found here [https://hodoku.sourceforge.net/en/techniques.php](https://hodoku.sourceforge.net/en/techniques.php). For the example board text above using all default strategies the summary might be
```
Solved: true
Filled cells at start: 29
Cells solveable 'by sudoku' (naked single): 4
Hidden singles: 11
Naked pairs: 0
Cells solveable 'by sudoku' after identifying naked pair: 0
Lines with locked, aligned candidates in same box: 1
Cells solveable 'by sudoku' after identifying locked, aligned candidates: 0
Lines with 'claimed' candidate from box intersecting two locked candidate lines: 13
Cells solveable 'by sudoku' after identifying 'claiming' line/box: 0
Hidden pairs: 5
Cells solveable 'by sudoku' after identifying a hidden pair: 0
Naked triples: 2
Cells solveable 'by sudoku' after identifying a naked triple: 37
Naked quadruples: 0
Cells solveable 'by sudoku' after identifying a naked quadruple: 0
Hidden triples: 0
Cells solveable 'by sudoku' after identifying a hidden triple: 0
X-Wings: 0
Cells solveable 'by sudoku' after identifying an x-wing: 0
Swordfishes: 0
Cells solveable 'by sudoku' after identifying a swordfish: 0
Passes: 1
```
Notice that a hidden pair was used to solve the board. So if you do not pass thru the `Strategy::HiddenPair` strategy to the solve, the summary may look a lot different:
```
Solved: true
Filled cells at start: 29
Cells solveable 'by sudoku' (naked single): 4
Hidden singles: 11
Naked pairs: 0
Cells solveable 'by sudoku' after identifying naked pair: 0
Lines with locked, aligned candidates in same box: 1
Cells solveable 'by sudoku' after identifying locked, aligned candidates: 0
Lines with 'claimed' candidate from box intersecting two locked candidate lines: 13
Cells solveable 'by sudoku' after identifying 'claiming' line/box: 0
Hidden pairs: 0
Cells solveable 'by sudoku' after identifying a hidden pair: 0
Naked triples: 1
Cells solveable 'by sudoku' after identifying a naked triple: 0
Naked quadruples: 0
Cells solveable 'by sudoku' after identifying a naked quadruple: 0
Hidden triples: 0
Cells solveable 'by sudoku' after identifying a hidden triple: 0
X-Wings: 1
Cells solveable 'by sudoku' after identifying an x-wings: 9
Swordfishes: 1
Cells solveable 'by sudoku' after identifying a swordfish: 28
Passes: 1
```
If you comment out enough strategies you may not even be able to solve the board at all!
Here is the summary without using the following strategies:
```rb
 Strategy::HiddenPair
 Strategy::NakedTriple
 Strategy::XWing
 Strategy::Swordfish
```
```
Solved: false
Filled cells at start: 29
Cells solveable 'by sudoku' (naked single): 4
Hidden singles: 11
Naked pairs: 0
Cells solveable 'by sudoku' after identifying naked pair: 0
Lines with locked, aligned candidates in same box: 1
Cells solveable 'by sudoku' after identifying locked, aligned candidates: 0
Lines with 'claimed' candidate from box intersecting two locked candidate lines: 13
Cells solveable 'by sudoku' after identifying 'claiming' line/box: 0
Hidden pairs: 0
Cells solveable 'by sudoku' after identifying a hidden pair: 0
Naked triples: 0
Cells solveable 'by sudoku' after identifying a naked triple: 0
Naked quadruples: 0
Cells solveable 'by sudoku' after identifying a naked quadruple: 0
Hidden triples: 0
Cells solveable 'by sudoku' after identifying a hidden triple: 0
X-Wings: 0
Cells solveable 'by sudoku' after identifying an x-wings: 0
Swordfishes: 0
Cells solveable 'by sudoku' after identifying a swordfish: 0
```

### A Sinatra server????
If you run `bundle exec puma` a web server will start up.
By passing a board string to the `/solve` endpoint like
```
http://0.0.0.0:9292/solve/1..6....9.9247..5......9.7...9....38.1..3..2.53....1...5.9......2..4586.8....1..4
```
The web app will respond with a json version of the entire solve history. The history is made up of an array of discrete _"redux-like"_ actions, like:
```json
[
  {"values":[6],"id":15183,"cascade":56,"solves":true,"cell_id":47,"type":"update_cell","strategy":"nakedpair","naked_buddies":[57,59]},
]
```
What's consuming this currently??.... nothing! But you could imagine a simple client side reducer that would allow you to replay the whole solve history step by step...

### Dev Notes
State management is complex: boards, row, columns, boxes, and cells all own the same underlying state! The program heavily adopts a redux-like pattern; board state can only be modified by calling a `register` method on the `Board::State` which then `dispatch`es an `Action` to the `Board::Reducer` which returns a new copy of the state. The state is made of primitve data types.

But! we still want to use nice, expressive OO abstractions, `Cell#empty?`, `Cell#has_candidate?`,  `Row.empty_cells`, etc.  The way this is resolved is that the domain objects don't really hold data of their own, but are synced up to the `Board::State`. To make a comparison to relational databses and ORMs, if the "redux-like" state is the equivalent of the DB here, the domain objects have a similar relationship to an in-memory object hydrated from the DB.

Initally, this ORM comparison was even more 1:1, you would hydrate an object from state, it held it's own data, the underlying state could change and the object might become stale
```ruby
# Bad / old
cell = board.state.get_cell(id)
# <Cell:0x00001 @id=1 @candidates=[2,4,7]>
puts cell.candidates
# => [2,4,7]
# ... then some action is dispatched to state that modifies the cell state
# ... so the candidates for the cell in state are [2,7]

puts cell.candidates
# => [2,4,7] # this is stale
```
Instead, the way this is implemnted now might be more equivelent to something like if for an ORM, every time you called `User#username` on a hydrated object it made a fresh DB query to get the current value. Here our "db calls" are cheap, just grabbing an element of an array at an index. You data is always in sync
```rb
# Good / new
cell = board.cells[id]
puts cell.candidates
#  <Cell:0x00001 @id=1> (doesnt hold candidates directly)
# => [2,4,7]
# ... then some action is dispatched to state that modifies the cell state
# ... so the candidates for the cell in state are [2,7]

puts cell.candidates
# => [2,7] # every call to #candidates re-reads from state
```
Even though individuals cells are always "synced" to the current state, when you grab a collection of objects based on the current state, and in a loop do something that modifies the state, subtle bugs can be caused if objects aren't in the state you think they are. For ex, below the only gurantee is that the cells were empty _when `board.empty_cells` was called_:
```rb
# Bad / old
board.empty_cells.each do |cell|
  # after an early iteration some cells that were originally empty may no longer be,
  # you'd need to add a guard clause if you expect these cells to really still be empty
  next unless cell.empty?
   # .. business logic ...
end
```
To resolve this, there are some "smart" enumerators provided that ensure the conditions you'd expect are upheld for each iteration.
```rb
# Good / new
board.each_empty_cell do |cell|
  # will only yield cells to the block that are empty at the moment it is yielded
  # .. business logic ...
end
```