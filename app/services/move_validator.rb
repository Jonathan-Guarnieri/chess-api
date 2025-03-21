class MoveValidator
  def initialize(movement)
    @movement = movement
  end

  def valid?
    return false if @movement.blank?

    @movement.valid?
  end
end
