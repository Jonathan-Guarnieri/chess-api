class Game < ApplicationRecord
  belongs_to :white_player, class_name: "User"
  belongs_to :black_player, class_name: "User"
  belongs_to :winner, class_name: 'User', optional: true

  enum win_type: {
    checkmate: 0,
    resignation: 1,
    timeout: 2,
    stalemate: 3,
    draw_agreement: 4,
    repetition: 5,
    insufficient_material: 6,
    abandoned: 7
  }

  validates :fen, presence: true, format: {
    with: /\A\s*(?:[rnbqkpRNBQKP1-8]{1,8}\/){7}[rnbqkpRNBQKP1-8]{1,8}\s[wb]\s(?:-|[KQkq]{1,4})\s(?:-|[a-h][36])\s\d+\s\d+\s*\z/i,
    message: "must be a valid FEN string"
  }

  validate :winner_presence_for_win_type

  private

  def winner_presence_for_win_type
    return if win_type.blank?

    if %w[checkmate resignation timeout].include?(win_type) && winner.nil?
      errors.add(:winner, "must be present for win type #{win_type}")
    end
  end
end
