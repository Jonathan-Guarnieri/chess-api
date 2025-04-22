class MatchmackerChannel < ApplicationCable::Channel
  def subscribed
    RedisClientWrapper.instance.rpush("matchmaker", current_user.id)
    stream_from "matchmaker_channel"

    if RedisClientWrapper.instance.llen("matchmaker") > 1
      players_ids = RedisClientWrapper.instance.lpop("matchmaker", 2)
      game = CreateGame.new(players_ids:)

      broadcast_to "matchmaker_channel", {
        action: 'match_found',
        game_id: game.id,
        white_player: game.white_player,
        black_player: game.black_player
      }
    end
  end

  def unsubscribed
    RedisClientWrapper.instance.lrem("matchmaker", current_user.id)
  end
end
