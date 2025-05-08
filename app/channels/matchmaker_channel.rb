class MatchmakerChannel < ApplicationCable::Channel
  def subscribed
    if lock_queue
      begin
        put_current_user_on_queue unless current_user_already_on_queue
        stream_from matchmaker_channel

        if queue_size >= 2
          game = create_game

          broadcast_to matchmaker_channel, {
            action: 'match_found',
            game_id: game.id,
            white_player: game.white_player,
            black_player: game.black_player
          }
        end
      ensure
        remove_lock
      end
    else
      connection.reject_subscription
    end
  end

  def unsubscribed
    remove_current_user_from_queue
  end

  private

  def matchmaker_channel
    "matchmaker_channel"
  end

  def redis
    RedisClientWrapper.instance
  end

  def queue_name
    "matchmaker"
  end

  def lock_key
    "matchmaker_lock"
  end

  def lock_token
    @lock_token ||= SecureRandom.uuid
  end

  def lock_queue
    redis.set(lock_key, lock_token, nx: true, ex: 3)
  end

  def remove_lock
    redis.del(lock_key)
  end

  def queue_size
    redis.llen(queue_name)
  end

  def put_current_user_on_queue
    redis.rpush(queue_name, current_user.id)
    Rails.logger.info "The User with ID #{current_user.id} just joined into queue"
  end

  def remove_current_user_from_queue
    redis.lrem(queue_name, current_user.id, 0)
    Rails.logger.info "The User with ID #{current_user.id} was just removed from queue"
  end

  def current_user_already_on_queue
    redis.lpos(queue_name, current_user.id)
  end

  def first_two_players_on_queue
    redis.lpop(queue_name, 2)
  end

  def create_game
    CreateGame.new(players_ids: first_two_players_on_queue).call
  end
end
