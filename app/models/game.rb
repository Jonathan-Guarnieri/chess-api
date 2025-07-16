class Game < ApplicationRecord
  INITIAL_FEN ||= Chess::Game.new.board.to_fen.freeze

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
    with: /\A((?:[PRNBQKprnbqk1-8]{1,8}\/){7}[RNBQKPrnbqkp1-8]{1,8})\s(w|b)\s(K?Q?k?q?|-)\s([a-h][1-8]|-)\s(\d+)\s(\d+)\z/,
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
