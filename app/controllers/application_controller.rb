require "base64"

class ApplicationController < ActionController::API
  attr_reader :current_user

  private

  def require_basic_auth!(expected_user_id: nil)
    header = request.headers["Authorization"]
    unless header&.start_with?("Basic ")
      Rails.logger.info("[auth] missing or non-basic Authorization header")
      render json: { message: "Authentication failed" }, status: :unauthorized and return
    end

    base64_token = header.split(" ", 2).last
    begin
      decoded = Base64.strict_decode64(base64_token.to_s)
    rescue ArgumentError
      Rails.logger.warn("[auth] base64 decode failed for Authorization token")
      render json: { message: "Authentication failed" }, status: :unauthorized and return
    end

    user_id, password = decoded.split(":", 2)
    Rails.logger.info("[auth] attempt user_id=#{user_id.inspect}")

    user = User.find_by(user_id: user_id)
    unless user&.authenticate(password.to_s)
      Rails.logger.warn("[auth] authentication failed for user_id=#{user_id.inspect}")
      render json: { message: "Authentication failed" }, status: :unauthorized and return
    end

    if expected_user_id.present? && expected_user_id != user.user_id
      Rails.logger.warn("[auth] forbidden update: token user=#{user.user_id.inspect} expected=#{expected_user_id.inspect}")
      render json: { message: "No permission for update" }, status: :forbidden and return
    end

    @current_user = user
    Rails.logger.info("[auth] authenticated user_id=#{user.user_id.inspect}")
  end
end
