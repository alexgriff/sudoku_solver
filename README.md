# Sudoku Solver
A Ruby program that solves sudokus.

## Instructions
Currently there's not a real CLI interface, so to interact with the program you can edit `cli.rb` \:shrug\:. `bundle install` and run `ruby cli.rb` \:shrug\:

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
`Solve`s can be passed the set of strategies you want to apply to the board. A lot of information about strategies and techniques can be found here [https://hodoku.sourceforge.net/en/techniques.php](https://hodoku.sourceforge.net/en/techniques.php). For the example board text above using all default strategies the summary might be
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
Cells solveable 'by sudoku' after identifying hidden pair: 0
Naked triples: 2
Cells solveable 'by sudoku' after identifying naked triple: 37
Naked quadruples: 0
Cells solveable 'by sudoku' after identifying naked quadruple: 0
Hidden triples: 0
Cells solveable 'by sudoku' after identifying Hidden triple: 0
X-Wings: 0
Cells solveable 'by sudoku' after identifying X-wings: 0
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
Cells solveable 'by sudoku' after identifying hidden pair: 0
Naked triples: 1
Cells solveable 'by sudoku' after identifying naked triple: 0
Naked quadruples: 0
Cells solveable 'by sudoku' after identifying naked quadruple: 0
Hidden triples: 0
Cells solveable 'by sudoku' after identifying Hidden triple: 0
X-Wings: 1
Cells solveable 'by sudoku' after identifying X-wings: 9
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
Cells solveable 'by sudoku' after identifying hidden pair: 0
Naked triples: 0
Cells solveable 'by sudoku' after identifying naked triple: 0
Naked quadruples: 0
Cells solveable 'by sudoku' after identifying naked quadruple: 0
Hidden triples: 0
Cells solveable 'by sudoku' after identifying Hidden triple: 0
X-Wings: 0
Cells solveable 'by sudoku' after identifying X-wings: 0
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
  # ...
	{"values":[6],"id":15183,"cascade":56,"solves":true,"cell_id":47,"type":"update_cell","strategy":"nakedpair","naked_buddies":[57,59]},
  # ...
]
```
What's consuming this currently??.... nothing! But you could imagine a simple client side reducer that would allow you to replay the whole solve history step by step...

### Dev Notes
