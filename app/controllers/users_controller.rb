class UsersController < ApplicationController
  def show
    require_basic_auth!
    user = User.find_by(user_id: params[:user_id])
    unless user
      render json: { message: "No user found" }, status: :not_found and return
    end

    render json: {
      message: "User details by user_id",
      user: user_response_hash(user)
    }, status: :ok
  end

  def update
    require_basic_auth!(expected_user_id: params[:user_id])
    user = current_user

    if params.key?(:user_id) || params.key?(:password)
      render json: { message: "User updation failed", cause: "Not updatable user_id and password" }, status: :bad_request and return
    end

    unless params.key?(:nickname) || params.key?(:comment)
      render json: { message: "User updation failed", cause: "Required nickname or comment" }, status: :bad_request and return
    end

    nickname = params[:nickname]
    comment  = params[:comment]

    if !nickname.nil?
      if nickname == ""
        user.nickname = nil
      else
        if nickname.length > 30 || !(nickname =~ User::NO_CONTROL_CODE_REGEX)
          render json: { message: "User updation failed", cause: "String length limit exceeded or containing invalid characters" }, status: :bad_request and return
        end
        user.nickname = nickname
      end
    end

    if !comment.nil?
      if comment == ""
        user.comment = nil
      else
        if comment.length > 100 || !(comment =~ User::NO_CONTROL_CODE_REGEX)
          render json: { message: "User updation failed", cause: "String length limit exceeded or containing invalid characters" }, status: :bad_request and return
        end
        user.comment = comment
      end
    end

    if user.save
      render json: {
        message: "User successfully updated",
        user: user_response_hash(user)
      }, status: :ok
    else
      render json: { message: "User updation failed", cause: "String length limit exceeded or containing invalid characters" }, status: :bad_request
    end
  end

  private

  def user_response_hash(user)
    data = { user_id: user.user_id, nickname: (user.nickname.presence || user.user_id) }
    data[:comment] = user.comment if user.comment.present?
    data
  end
end
