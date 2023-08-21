class Board::History
  def initialize()
    @log = []
  end

  def <<(next_action)
    @log << next_action
  end

  def [](index)
    @log[index]
  end

  def all
    @log.dup
  end

  def last(n=1)
    @log.last(n)
  end

  def length
    @log.length
  end

  def find(**kwargs)
    where(**kwargs).first
  end

  def where(**kwargs)
    @log.select do |action|
      kwargs.all? do |key, val|
        action.send(key) == val
      end
    end
  end

  def after(action_id)
    start_index = @log.index { |action| action.id == action_id }
    @log[start_index..-1]
  end

  def up_to(action_id)
    end_index = @log.index { |action| action.id == action_id }
    @log[0..end_index]
  end

  def action_previous_to(other_action)
    other_action_index = @log.index { |action| action == other_action }
    @log[other_action_index - 1]
  end

  def reset
    @log = []
  end
end
