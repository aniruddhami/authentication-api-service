class ApplicationController < ActionController::API
  attr_reader :current_user

  private

  def require_basic_auth!(expected_user_id: nil)
    header = request.headers["Authorization"]
    unless header&.start_with?("Basic ")
      render json: { message: "Authentication failed" }, status: :unauthorized and return
    end

    base64_token = header.split(" ", 2).last
    begin
      decoded = Base64.strict_decode64(base64_token.to_s)
    rescue ArgumentError
      render json: { message: "Authentication failed" }, status: :unauthorized and return
    end

    user_id, password = decoded.split(":", 2)
    user = User.find_by(user_id: user_id)
    unless user&.authenticate(password.to_s)
      render json: { message: "Authentication failed" }, status: :unauthorized and return
    end

    if expected_user_id.present? && expected_user_id != user.user_id
      render json: { message: "No permission for update" }, status: :forbidden and return
    end

    @current_user = user
  end
end
