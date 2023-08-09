class Board::History
  def initialize()
    @history = []
  end

  def <<(next_action)
    @history << next_action
  end

  def [](index)
    @history[index]
  end

  def all
    @history.dup
  end

  def last(n=1)
    @history.last(n)
  end

  def length
    @history.length
  end

  def find(**kwargs)
    where(**kwargs).first
  end

  def after_id(action_id)
    start_index = @history.index { |action| action.id == action_id }
    @history[start_index..-1]
  end

  def where(**kwargs)
    @history.select do |action|
      kwargs.all? do |key, val|
        if val == nil
          !action.respond_to?(key) || !action.send(key)
        else
          action.respond_to?(key) ? action.send(key) == val : false
        end
      end
    end
  end
end
