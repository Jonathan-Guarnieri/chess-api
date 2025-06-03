class MatchmakerJob
  include Sidekiq::Job
  sidekiq_options queue: :default

  def perform
    matchmaker = MatchmakerService.new
    matchmaker.call

    try_again_later if matchmaker.try_again_later?
  end

  private

  def try_again_later
    interval_str = ENV['MATCHMAKER_RETRY_INTERVAL_MS']
    raise 'You need to set MATCHMAKER_RETRY_INTERVAL_MS env' unless interval_str

    interval_ms = Integer(interval_str)
    self.class.perform_in(interval_ms / 1000.0)
  end
end
