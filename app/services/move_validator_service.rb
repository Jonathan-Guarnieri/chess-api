class MoveValidatorService < ApplicationService
  def initialize(from_square:, to_square:, board_state:)
    @from_square = from_square
    @to_square = to_square
    @board_state = board_state
  end

  def valid?
    piece = @board_state[@from_square]

    case @piece.type
    when 'Knight'
      valid_knight_move?
    when 'Bishop'
      valid_bishop_move?
    when 'Rook'
      valid_rook_move?
    when 'Queen'
      valid_queen_move?
    when 'King'
      valid_king_move?
    when 'Pawn'
      valid_pawn_move?
    else
      false
    end

    private

    def valid_knight_move?
      # Knights move in an L shape: two squares in one direction and then one square perpendicular
      dx = (@to_square.x - @from_square.x).abs
      dy = (@to_square.y - @from_square.y).abs
      (dx == 2 && dy == 1) || (dx == 1 && dy == 2)
    end
  end
end
