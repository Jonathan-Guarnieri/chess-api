class MatchmakerChannel < ApplicationCable::Channel
  def subscribed
    MatchmakerQueue.add(current_user.id)
    stream_for current_user
    MatchmakerJob.perform_async
  end

  def unsubscribed
    MatchmakerQueue.remove(current_user.id)
  end
end
