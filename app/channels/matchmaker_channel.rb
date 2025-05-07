class MatchmakerChannel < ApplicationCable::Channel
  def subscribed
    put_current_user_on_queue
    stream_from matchmaker_channel

    if queue > 1
      p "MatchmakerChannel is trying to create a new match!"
      game = CreateGame.new(players_ids: first_two_players_on_queue).call
      p "A game was created: #{game}"

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

  def queue_name
    "matchmaker"
  end

  def matchmaker_channel
    "matchmaker_channel"
  end

  def redis
    RedisClientWrapper.instance
  end

  def queue
    redis.llen(queue_name)
  end

  def remove_current_user_from_queue
    redis.lrem(queue_name, current_user.id, 0)
    p "The User with ID #{current_user.id} was just removed from queue"
  end

  def put_current_user_on_queue
    redis.rpush(queue_name, current_user.id)
    p "The User with ID #{current_user.id} just joined into queue"
  end

  def first_two_players_on_queue
    redis.lpop(queue_name, 2)
  end
end
