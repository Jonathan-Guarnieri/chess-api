class MatchmackerChannel < ApplicationCable::Channel
  def subscribed
    put_current_user_on_queue
    stream_from matchmaker_channel

    if matchmacker_redis_queue > 1
      game = CreateGame.new(players_ids: first_two_players_on_queue)

      broadcast_to matchmaker_channel, {
        action: 'match_found',
        game_id: game.id,
        white_player: game.white_player,
        black_player: game.black_player
      }
    end
  end

  def unsubscribed
    remove_current_user_from_queue
  end

  private

  def redis_queue_name
    "matchmaker"
  end

  def matchmaker_channel
    "matchmaker_channel"
  end

  def redis
    RedisClientWrapper.instance
  end

  def redis_queue
    redis.llen(redis_queue_name)
  end

  def remove_current_user_from_queue
    redis.lrem(redis_queue_name, current_user.id)
  end

  def put_current_user_on_queue
    redis.rpush(redis_queue_name, current_user.id)
  end

  def first_two_players_on_queue
    redis.lpop(redis_queue_name, 2)
  end
end
