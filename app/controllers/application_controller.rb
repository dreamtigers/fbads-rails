class ApplicationController < ActionController::Base
  private

  def current_user
    @current_user ||= FbUser.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user
end
