module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    def disconnect
      # clean Matchmaker if user disconnects unexpectedly
      MatchmakerQueue.remove(current_user.id)
    rescue => e
      Rails.logger.error("Failed to clean queue on disconnect: #{e.message}")
    end

    private

    def find_verified_user
      if (user = env['warden'].user)
        user
      else
        reject_unauthorized_connection
      end
    end
  end
end
