class Square
  # This is a virtual model representing a square on the chessboard.
  # It does not correspond to a database table but is used for validation purposes.
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :address

  validate :valid_address

  def x
    case address[0]
    when 'a' then 1
    when 'b' then 2
    when 'c' then 3
    when 'd' then 4
    when 'e' then 5
    when 'f' then 6
    when 'g' then 7
    when 'h' then 8
    else nil
    end
  end

  def y
    address[1].to_i
  end

  private

  def valid_address
    return errors.add(:address, 'must be present') unless address
    return errors.add(:address, 'must be a string') unless address.is_a?(String)
    return errors.add(:address, 'must be 2 characters long') unless address.length == 2
    return errors.add(:address, 'must start with a valid letter (a-h)') unless address[0].match?(/^[a-h]/)
    return errors.add(:address, 'must end with a valid digit (1-8)') unless address[1].match?(/.[1-8]$/)

    true
  end
end
