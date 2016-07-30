class UsersController < ApplicationController
  def create
    @user = User.create(user_params)
    session[:current_user_id] = @user.id.to_s
    render :show
  end

  def me
    @user = current_user
    render :show
  end

  def user_params
    params.require(:user).permit(:name)
  end
end
