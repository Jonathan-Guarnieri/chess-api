RSpec::Matchers.define :acquire_and_release_redis_lock do |expected_lock_key|
  match do |block|
    redis = RedisClientWrapper.instance
    @initial_value = redis.get(expected_lock_key)
    raise "Expected Redis key '#{expected_lock_key}' to be nil before block" unless @initial_value.nil?

    before = redis.get(expected_lock_key)
    block.call
    after = redis.get(expected_lock_key)

    before.nil? && after.nil?
  end

  failure_message do
    "\nexpected to acquire and release redis lock '#{expected_lock_key}', but it did not.\n"
  end

  supports_block_expectations
end
