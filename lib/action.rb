class Action
  INIT = :init
  NEW_BOARD_SYNC = :new_board_sync
  FILL_CELL = :fill_cell
  UPDATE_CELL = :update_cell
  NEW_PASS = :new_pass
  DONE = :done
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
end
