class GameChannel < ApplicationCable::Channel
  def subscribed
    # game_id = params[:id]
    # stream_from "game_#{game_id}"
    stream_from "game_1"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def test
    # ActionCable.server.broadcast("game_1", {message: 'test'})
    transmit({ message: 'test ok' })
  end
end
