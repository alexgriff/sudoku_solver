class Cell
  EMPTY = '.'
  ALL_CANDIDATES = (1..9).to_a

  def self.from_state(id:, state:)

    new(
      id: id,
      value: state[:value] || EMPTY,
      candidates: state[:candidates]
    )
  end

  attr_reader :id, :value, :candidates

  def initialize(id:, candidates: nil, value: EMPTY)
    @id = id
    @value = value
    @candidates = filled? ? [] : (candidates || ALL_CANDIDATES.dup)
  end

  def row_id
    @row_id ||= id / 9
  end

  def column_id
    @column_id ||= id % 9
  end

  def box_id
    @box_id ||= column_id / 3 + row_id / 3 * 3
  end

  def empty?
    value == EMPTY
  end

  def filled?
    !empty?
  end

  def has_one_remaining_candidate?
    candidates.length == 1
  end

  def has_candidate?(candidate)
    candidates.include? candidate
  end

  def candidate_permutations(n)
    candidates.permutation(n).uniq { |perm| perm.sort }
  end
end
