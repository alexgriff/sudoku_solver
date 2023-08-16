# Sudoku Solver
A Ruby program that solves sudokus.


## Instructions
Currently you can interact with the program via a CLI app. Run:
```sh
ruby sudoku.rb --help
```
For usage instructions and useful tips.

Sudoku boards generated from [https://qqwing.com/generate.html](https://qqwing.com/generate.html) can be copied pasted into this program. Currently the program should be able to solve any 'Simple', 'Easy', or 'Intermediate' boards and some 'Expert' boards.

It's easiest use boards in the 'One line' format, which will look like
```txt
1..6....9.9247..5......9.7...9....38.1..3..2.53....1...5.9......2..4586.8....1..4
```

But other text formats can be passed into the program as well outside of the CLI interface
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

### Strategies
Each "solve" can be passed the set of strategies you want to apply to the board. Lots of information about strategies and techniques can be found here [https://hodoku.sourceforge.net/en/techniques.php](https://hodoku.sourceforge.net/en/techniques.php).

By default, the CLI uses all of the following strategies which can be viewed with `ruby sudoku.rb -s`

```
1  - Hidden single
2  - Naked pair
3  - Locked candidates pointing
4  - Locked candidates claiming
5  - Naked triple
6  - Naked quadruple
7  - Hidden pair
8  - X wing
9  - Swordfish
10 - Hidden triple
11 - Y wing
12 - Skyscraper
```

In the solve summary, you can see the how the strategies were applied to the board. So for example, solving the example board above might output a summary like

```sh
ruby sudoku.rb -b 1..6....9.9247..5......9.7...9....38.1..3..2.53....1...5.9......2..4586.8....1..4
```
```
Solved: true
Cells filled at start: 29
Cells initially solveable 'by sudoku' (Naked single): 4
Hidden singles: 11
Naked pairs: 0
  cells solved 'by sudoku' after identifying naked pair: 0
Locked lines: 1
  cells solved 'by sudoku' after locked line in box: 0
Claimed lines: 0
  cells solved 'by sudoku' after identifying 'claiming' line/box: 0
Naked triples: 1
  cells solved 'by sudoku' after identifying a naked triple: 0
Naked quadruples: 0
  cells solved 'by sudoku' after identifying a naked quadruple: 0
Hidden pairs: 1
  cells solved 'by sudoku' after identifying a hidden pair: 0
X-Wings: 1
  cells solved 'by sudoku' after identifying an x-wing: 9
Swordfishes: 1
  cells solved 'by sudoku' after identifying a swordfish: 28
Hidden triples: 0
  cells solved 'by sudoku' after identifying a hidden triple: 0
Y-Wings: 0
  cells solved 'by sudoku' after identifying a y-wing: 0
Skyscrapers: 0
  cells solved 'by sudoku' after identifying a skyscraper: 0
Passes: 1
```
If you solve the board excluding some of the more advanced strategies, the summary may look a lot of different

```sh
ruby sudoku.rb -e 7,8,9,10,12 -b 1..6....9.9247..5......9.7...9....38.1..3..2.53....1...5.9......2..4586.8....1..4
```
```
Solved: true
Cells filled at start: 29
Cells initially solveable 'by sudoku' (Naked single): 4
Hidden singles: 20
Naked pairs: 1
  cells solved 'by sudoku' after identifying naked pair: 28
Locked lines: 1
  cells solved 'by sudoku' after locked line in box: 0
Claimed lines: 0
  cells solved 'by sudoku' after identifying 'claiming' line/box: 0
Naked triples: 1
  cells solved 'by sudoku' after identifying a naked triple: 0
Naked quadruples: 0
  cells solved 'by sudoku' after identifying a naked quadruple: 0
Y-Wings: 0
  cells solved 'by sudoku' after identifying a y-wing: 0
Passes: 2
```
If you include only a small enough set of strategies you may not even be able to solve the board at all! The following is the summary only using 4 strategies:

```sh
ruby sudoku.rb -i 1,2,3,4 -b 1..6....9.9247..5......9.7...9....38.1..3..2.53....1...5.9......2..4586.8....1..4
```
```
Solved: false
Cells filled at start: 29
Cells initially solveable 'by sudoku' (Naked single): 4
Hidden singles: 11
Naked pairs: 0
  cells solved 'by sudoku' after identifying naked pair: 0
Locked lines: 1
  cells solved 'by sudoku' after locked line in box: 0
Claimed lines: 0
  cells solved 'by sudoku' after identifying 'claiming' line/box: 0
Passes: 2
```

### A Sinatra server????
If you run `bundle exec puma` a web server will start up.
By passing a board string to the `/solve` endpoint like
```
http://0.0.0.0:9292/solve/1..6....9.9247..5......9.7...9....38.1..3..2.53....1...5.9......2..4586.8....1..4
```
The web app will respond with a json version of the entire solve history. The history is an array of discrete _"redux-like" actions_, ie plain objects like:
```json
{
  "id":22,
  "type":"update_cell",
  "cell_id":50,
  "values":[2,6,7],
  "strategy":"hidden_single",
  "cascaded_from_id":20
}
```
What's consuming this currently??.... nothing! But you could imagine a fairly simple client side reducer that would allow you to replay the whole solve history step by step... that's coming next perhaps.

### Dev Notes
State management is complicated: boards, row, columns, boxes, and cells all own the same underlying state! As mentioned, the program adopts a redux-like pattern; board state can only be modified by calling a `register` method on the `Board::State` which then `dispatch`es an `Action` to the `Board::Reducer` which returns the new state. The elements of the state are made of primitve data types.

But! we still want to use nice, expressive OO abstractions, `Cell#empty?`, `Cell#has_candidate?`, `Row#empty_cells`, etc.  To support this, domain objects don't really hold data of their own, but are synced up to the `Board::State` and always read from it to determine their current values.

A decent mental model is an ORM. As an equivalent to the database in an ORM we have the "redux-like" board state which objects are created from. The pattern here differs a bit from the ORM model in that in an ORM the in-memory object pulled from the db can have stale values if the underlying db changes after initially being read. Here, since domain objects don't actually hold their own data, but _read from state every time you access their properties_, the values cannot be stale. The analogy might be if in an ORM every time you accessed a propery of an object, something like `user.username`, it made a fresh db query to get the current value of the property. That might be a bad pattern in an ORM, but here our "db call" equivalents are cheap, just grabbing an element of an array at an index, and there's only one actor operating on the underlying state. The result is that you can be ensured a `Cell` object is always giving you an up-to-date value.

Even though individuals cells are always "synced" to the current state, when you grab a collection of objects based board state in some way, and in a loop do something that modifies the state, subtle bugs can be caused if objects aren't in the state you think they are. For ex, below the only guarantee is that the cells were empty _when `board.empty_cells` was called_:
```rb
# Bad
board.empty_cells.each do |cell|
  # if a previous iteration filled a cell it may no longer be empty when it's turn in the loop occurs
  # you'd need to add a guard clause if you expect these cells to really still be empty
  next unless cell.empty?
   # .. business logic ...
end
```
To ease having to think about these types of staleness issues, there are some "smart" enumerators provided that ensure the conditions you'd expect are upheld for each iteration.
```rb
# Good
board.each_empty_cell do |cell|
  # will only yield cells to the block that are empty at the moment it is yielded
  # .. business logic ...
end
```
