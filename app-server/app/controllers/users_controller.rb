class UsersController < ApplicationController
  def create
    @user = User.create(user_params)
    if @user.persisted?
      session[:current_user_id] = @user.id.to_s
      render :show
    else
      render nothing: true, status: :bad_request
    end
  end

  def me
    @user = current_user
    render :show
  end

  def user_params
    params.require(:user).permit(:name)
  end
end
