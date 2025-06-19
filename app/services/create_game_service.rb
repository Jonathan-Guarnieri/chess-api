class CreateGameService < ApplicationService
  # TODO: Prevent game creation if either user is already in an active game

  def initialize(player_ids:)
    @player_ids = player_ids
  end

  def call
    players = User.where(id: @player_ids)
    raise "Should have exactly 2 players, found #{players.size}" if players.size != 2

    white_player, black_player = players.sample(2)

    Game.create!(white_player:, black_player:)
  end
end
