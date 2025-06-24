class MatchmakerService < ApplicationService
  # Creates a game if there are two available players

  def initialize
    @try_again_later = true
  end

  def call
    begin
      Rails.logger.info "[MatchmakerService]: Starting matchmaker process"
      return unless acquire_lock

      if MatchmakerQueue.size >= 2
        Rails.logger.info "[MatchmakerService]: Enough players in queue, proceeding to create game"
        player_ids = MatchmakerQueue.pop(2)

        CreateGameService.call(player_ids:)
        Rails.logger.info "[MatchmakerService]: Game created for players: #{player_ids.join(', ')}"

        player_ids.each do |player_id|
          Rails.logger.info "[MatchmakerService]: Broadcasting match found for player #{player_id}"
          MatchmakerChannel.broadcast_to(player_id, { action: "match_found" })
        end
      else
        Rails.logger.info "[MatchmakerService]: Not enough players in queue, will try again later"
        @try_again_later = true
      end
    ensure
      release_lock
      @try_again_later = false if MatchmakerQueue.size == 0
    end
  end

  def try_again_later?
    @try_again_later
  end

  private

  def redis
    RedisClientWrapper.instance
  end

  def lock_key
    "matchmaker_lock"
  end

  def lock_token
    @lock_token ||= SecureRandom.uuid
  end

  def acquire_lock
    redis.set(lock_key, lock_token, nx: true, ex: 3)
  end

  def release_lock
    redis.eval(<<~LUA, keys: [ lock_key ], argv: [ lock_token ])
      if redis.call("get", KEYS[1]) == ARGV[1] then
        return redis.call("del", KEYS[1])
      else
        return 0
      end
    LUA
  end
end
