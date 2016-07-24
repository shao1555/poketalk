class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.create(user_params)
    if @user.present?
      flash[:message] = 'saved'
      redirect_to :index
    else
      flash[:error] = 'can not save'
      redirect_to :new
    end
  end

  def login
    session[:current_user] = @user
    flash[:message] = "logged in as #{@user.name}"
    redirect_to :index
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name)
  end
end
