class Action
  INIT = :init
  NEW_BOARD_SYNC = :new_board_sync
  UPDATE_CELL = :update_cell
  NEW_PASS = :new_pass
  DONE = :done
  CLONE = :clone
  @@id = 1
  
  attr_reader :type, :id

  def initialize(type:, **kwargs)
    @id = @@id
    @type = type

    kwargs.each_key do |key|
      instance_variable_set("@#{key}", kwargs[key])
      singleton_class.instance_eval { attr_accessor key }
    end
    @@id += 1
  end

  def method_missing(_method_name)
    nil
  end

  def as_json(options={})
    instance_variables.each_with_object({}) do |ivar, obj|
      ivar_name = ivar.to_s[1..-1]
      obj[ivar_name] = send(ivar_name)
    end
  end

  def to_json(*options)
    as_json(*options).to_json(*options)
  end
end
