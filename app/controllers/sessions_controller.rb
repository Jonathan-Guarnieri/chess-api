# frozen_string_literal: true

class SessionsController < Devise::SessionsController
  include ActionController::Cookies

  respond_to :json

  def create
    super do |user|
      if user.persisted?
        token = request.env["warden-jwt_auth.token"]
        cookies.signed[:jwt_token] = {
          value: token,
          httponly: true,
          secure: Rails.env.production?,
          same_site: :lax,
          expires: 1.day.from_now
        }
      end
    end
  end

  private

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: { message: "Logged in." }, status: :ok
    else
      render json: { message: "Authentication failed." }, status: :unauthorized
    end
  end

  def respond_to_on_destroy
    cookies.delete(:jwt_token)
    head :ok
  end
end
