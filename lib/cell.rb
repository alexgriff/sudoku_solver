class Cell
  EMPTY = '.'
  ALL_CANDIDATES = (1..9).to_a

  attr_reader :id, :value, :candidates

  def initialize(id:, candidates: nil, value: EMPTY)
    @id = id
    @value = value
    @candidates = filled? ? [] : (candidates || ALL_CANDIDATES.dup)
  end

  def row_id
    @row_id ||= id / Board::SIZE
  end

  def row(board)
    board.rows[row_id]
  end

  def column_id
    @column_id ||= id % Board::SIZE
  end

  def column(board)
    board.columns[column_id]
  end

  def box_id
    @box_id ||= column_id / 3 + row_id / 3 * 3
  end

  def box(board)
    board.boxes[box_id]
  end

  def houses(board)
    [
      row(board),
      column(board),
      box(board)
    ]
  end

  def empty?
    value == EMPTY
  end

  def filled?
    !empty?
  end

  def has_any_of_candidates?(cands)
    intersecting_candidates(cands).length > 0
  end

  def has_all_of_candidates?(cands)
    intersecting_candidates(cands).length == cands.length
  end

  def intersecting_candidates(cands)
    (candidates & cands)
  end

  def candidate_permutations(n)
    candidates.permutation(n).uniq { |perm| perm.sort }
  end
end
