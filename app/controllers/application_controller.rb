class ApplicationController < ActionController::Base
  private

  def current_user
    @current_user ||= FbUser.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user

  def require_login
    # If we're logged in, simply return
    return if current_user

    # Otherwise redirect to '/'
    redirect_to root_url, alert: 'You must be logged in to access this section'
  end
  helper_method :require_login
end
