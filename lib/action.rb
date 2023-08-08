class Action
  INIT = :init
  INIT_CELL = :init_cell
  NEW_PASS = :new_pass
  UPDATE_CELL = :update_cell
  @@id = 1
  
  attr_reader :type

  def initialize(type:, **kwargs)
    @id = @@id
    @type = type

    kwargs.each_key do |key|
      instance_variable_set("@#{key}", kwargs[key])
      singleton_class.instance_eval { attr_accessor key }
    end
    @@id += 1
  end
end
