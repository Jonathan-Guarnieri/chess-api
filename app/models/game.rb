class Game < ApplicationRecord
  INITIAL_FEN ||= "rn1qkbnr/pppb1ppp/8/3pp3/8/5NP1/PPPPPPBP/RNBQK2R w KQkq - 0 1".freeze

  belongs_to :white_player, class_name: "User"
  belongs_to :black_player, class_name: "User"
  belongs_to :winner, class_name: "User", optional: true

  enum :win_type, [ :checkmate,
                    :resignation,
                    :timeout,
                    :stalemate,
                    :draw_agreement,
                    :repetition,
                    :insufficient_material,
                    :abandoned ]

  before_validation :set_initial_fen, on: :create

  validates :fen, presence: true, format: {
    with: /\A\s*(?:[rnbqkpRNBQKP1-8]{1,8}\/){7}[rnbqkpRNBQKP1-8]{1,8}\s[wb]\s(?:-|[KQkq]{1,4})\s(?:-|[a-h][36])\s\d+\s\d+\s*\z/i,
    message: "must be a valid FEN string"
  }

  validate :winner_presence_for_win_type

  private

  def set_initial_fen
    self.fen ||= INITIAL_FEN
  end

  def winner_presence_for_win_type
    return if win_type.blank?

    if %w[checkmate resignation timeout].include?(win_type) && winner.nil?
      errors.add(:winner, "must be present for win type #{win_type}")
    end
  end
end
