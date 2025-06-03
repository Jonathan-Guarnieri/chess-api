class MatchmakerService < ApplicationService
  # Creates a game if there are two available players

  def initialize
    @try_again_later = true
  end

  def call
    begin
      return unless acquire_lock

      if MatchmakerQueue.size >= 2
        player_ids = MatchmakerQueue.pop(2)
        # TODO: Prevent game creation if either user is already in an active game

        CreateGameService.call(player_ids:)

        player_ids.each do |player_id|
          MatchmakerChannel.broadcast_to(player_id, { action: "match_found" })
        end
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
