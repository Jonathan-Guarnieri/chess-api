class MatchmakerJob < ApplicationJob
  queue_as :default

  def perform
    matchmaker = MatchmakerService.new
    matchmaker.call

    try_again_later if matchmaker.try_again_later?
  end

  private

  def try_again_later
    interval_ms = ENV['MATCHMAKER_RETRY_INTERVAL_MS']
    raise 'You need to set MATCHMAKER_RETRY_INTERVAL_MS env' unless interval_ms

    self.class.perform_in(interval_ms.milliseconds)
  end
end
