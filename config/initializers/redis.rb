module RedisClientWrapper
  def self.instance
    @instance ||= ::Redis.new(
      url: ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" },
      timeout: 5,
      reconnect_attempts: 1
    )
  end
end
