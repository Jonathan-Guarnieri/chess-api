class Game < ApplicationRecord
  belongs_to :white_player
  belongs_to :black_player
  belongs_to :winner
end
