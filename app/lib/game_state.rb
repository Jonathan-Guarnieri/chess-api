class GameState
  # Provide helper methods to handle the game state inside redis

  KEY = "game_state"

  def initialize(game_id, white_player:nil, black_player:nil)
    @game_id = game_id
    @white_player = white_player
    @black_player = black_player
  end

  def create
    raise "[GameState] Game with id #{@game_id} already initialized" if redis.exists?(redis_key)
    unless @white_player && @black_player
      raise "[GameState] Needs to receive a white_player and black_player on the initializer when using the 'create' method"
    end

    data = {
      fen: Game::INITIAL_FEN,
      white_player: @white_player,
      black_player: @black_player
    }

    save data
  end

  def update(data)
    raise "[GameState] Game with id #{@game_id} does not exists" unless redis.exists?(redis_key)
    raise '[GameState] invalid data to update' unless data.is_a? Hash && data.transform_keys(&:to_s)['fen']

    data = data.transform_keys(&:to_s)
    fen = data['fen']
    data = { fen: }

    save data
  end

  def delete
    redis.del(redis_key)
  end

  def players
    result = redis.hmget(redis_key, 'white_player', 'black_player')
    { white_player: result[0], black_player: result[1] }
  end

  def state
    redis.hgetall(redis_key)
  end

  private

  def redis
    RedisClientWrapper.instance
  end

  def redis_key
    raise "[GameState] required value: @game_id" unless @game_id

    "#{KEY}:#{@game_id}"
  end

  def save(data)
    valid_keys = %w[fen white_player black_player]

    unless data.is_a?(Hash)
      raise "[GameState] invalid data. Should be a Hash. Got: #{data&.class}" 
    end

    data = data.transform_keys(&:to_s).transform_values(&:to_s)

    data.each do |k, _|
      unless k.in?(valid_keys)
        raise "[GameState] invalid key #{k}. Valid keys: #{valid_keys}."
      end
    end

    raise '[GameState] Needs to have fen' unless data['fen']

    redis.hset(redis_key, data)
  end
end
