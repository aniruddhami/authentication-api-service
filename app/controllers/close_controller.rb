class CloseController < ApplicationController
  def create
    require_basic_auth!
    current_user.destroy!
    render json: { message: "Account and user successfully removed" }, status: :ok
  end
end
