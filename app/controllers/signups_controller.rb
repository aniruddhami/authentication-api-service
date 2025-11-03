class SignupsController < ApplicationController
  def create
    user_id = params[:user_id].to_s
    password = params[:password].to_s

    if user_id.empty? || password.empty?
      render json: { message: "Account creation failed", cause: "Required user_id and password" }, status: :bad_request and return
    end

    unless (6..20).cover?(user_id.length) && (8..20).cover?(password.length)
      render json: { message: "Account creation failed", cause: "Input length is incorrect" }, status: :bad_request and return
    end

    unless user_id.match?(User::VALID_USER_ID_REGEX) && password.match?(User::VALID_ASCII_NO_SPACE_REGEX)
      render json: { message: "Account creation failed", cause: "Incorrect character pattern" }, status: :bad_request and return
    end

    if User.exists?(user_id: user_id)
      render json: { message: "Account creation failed", cause: "Already same user_id is used" }, status: :bad_request and return
    end

    user = User.new(user_id: user_id, password: password)
    user.nickname = user_id
    if user.save
      render json: {
        message: "Account successfully created",
        user: { user_id: user.user_id, nickname: user.nickname }
      }, status: :ok
    else
      # Fallback validation error (should be covered by manual checks above)
      render json: { message: "Account creation failed", cause: "Input length is incorrect" }, status: :bad_request
    end
  end
end
