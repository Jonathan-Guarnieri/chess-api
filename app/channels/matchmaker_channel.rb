class MatchmakerChannel < ApplicationCable::Channel
  def subscribed
    MatchmakerQueue.add(current_user.id)
    stream_for current_user
    MatchmakerJob.perform_async
  end

  def unsubscribed
    MatchmakerQueue.remove(current_user.id)
  end

  def keep_alive
    if MatchmakerQueue.include?(current_user.id)
      MatchmakerQueue.add(current_user.id)
    else
      broadcast_to(current_user, { action: "not_subscribed" })
    end
  end
end
