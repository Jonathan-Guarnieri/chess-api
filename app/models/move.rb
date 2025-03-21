class Move < ApplicationRecord
  belongs_to :piece

  attribute :from_square
  attribute :to_square
end
