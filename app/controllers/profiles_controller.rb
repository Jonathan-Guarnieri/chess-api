class ProfilesController < ApplicationController
  def me
    render json: UserSerializer.new(current_user).serializable_hash.to_json
  end
end
