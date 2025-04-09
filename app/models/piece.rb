class Piece < ApplicationRecord
  enum :piece_type, {
    knight: 0,
    bishop: 1,
    rook: 2,
    queen: 3,
    king: 4,
    pawn: 5
  }

  validates_presence_of :piece_type
end
