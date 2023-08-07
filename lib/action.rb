class Action
  INIT = :init
  NEW_PASS = :new_pas
  FILL_CELL = :fill_cell
  UPDATE_CANDIDATES = :update_candidates
  
  attr_reader :type

  def initialize(type:, **kwargs)
    @type = type

    kwargs.each_key do |key|
      instance_variable_set("@#{key}", kwargs[key])
      singleton_class.instance_eval { attr_accessor key }
    end
  end
end
