class GameChannel < ApplicationCable::Channel
  def subscribed
    game_id = params[:id]
    stream_from "game_#{game_id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def move(data)
    # validator = MoveValidator.new(from_square: data['from'], to_square: data['to'], board_state:)
    broadcast_to "game_#{params[:id]}", {
      action: 'move_validator_result',
      valid: true 
    }
  end

  # private

  # def board_state
  #   RedisClientWrapper.instance.get()
  # end
end
