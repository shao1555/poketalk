class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_user

  force_ssl if: :use_ssl?

  def use_ssl?
    Rails.env.production? && request.env['HTTP_X_FORWARDED_FOR'].present?
  end

  def current_user
    User.where(id: session[:current_user_id]).first
  end
end
