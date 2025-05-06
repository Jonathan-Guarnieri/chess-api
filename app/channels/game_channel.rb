class GameChannel < ApplicationCable::Channel
  def subscribed
    game_id = params.dig(:opts, :gameId)
    unless game_id.is_a?(Integer)
      raise "unable to find a valid game_id from params: #{params}"
    end

    stream_from "game_#{game_id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def move(data)
    # validator = MoveValidator.new(from_square: data['from'], to_square: data['to'], board_state:)
    ActionCable.server.broadcast "game_#{params[:id]}", {
      action: 'move_validator_result',
      valid: true 
    }
  end

  # private

  # def board_state
  #   RedisClientWrapper.instance.get()
  # end
end
