class MatchmakerQueue
  # Provide helper methods to handle redis queue
  # Always purge expired user_id entries before reading the queue

  KEY = "matchmaker"

  class << self
    def add(user_id)
      ttl = ENV["MATCHMAKER_ENQUEUE_TTL_SECONDS"]&.to_f
      raise "MATCHMAKER_ENQUEUE_TTL_SECONDS env not set or invalid" unless ttl&.positive?

      expire_at = Time.now.to_f + ttl
      redis.zadd(KEY, expire_at, user_id)
      Rails.logger.info("User #{user_id} added to matchmaker queue with TTL #{ttl}s")
    end

    def remove(user_id)
      redis.zrem(KEY, user_id)
      Rails.logger.info("User #{user_id} removed from matchmaker queue")
    end

    def pop(count)
      # TODO: Nedds to return the user(s) that entered the queue first
      purge_expired_user_id_entries
      return [] unless count.is_a?(Integer) && count.positive?

      users = redis.zrange(KEY, 0, count - 1)
      redis.zrem(KEY, users) unless users.empty?
      users
    end

    def size
      purge_expired_user_id_entries
      redis.zcard(KEY)
    end

    def all
      purge_expired_user_id_entries
      redis.zrange(KEY, 0, -1)
    end

    def include?(user_id)
      purge_expired_user_id_entries
      redis.zscore(KEY, user_id).present?
    end

    private

    def redis
      RedisClientWrapper.instance
    end

    def purge_expired_user_id_entries
      redis.zremrangebyscore(KEY, "-inf", Time.now.to_f)
    end
  end
end
