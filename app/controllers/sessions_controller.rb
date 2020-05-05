class SessionsController < ApplicationController
  def create
    fb_user = FbUser.from_omniauth(request.env['omniauth.auth'])
    session[:user_id] = fb_user.id
    redirect_to edit_setting_path(fb_user)
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url
  end

  private

  def fb_user_params
    params.require(:fb_user).permit(
      :uid,
      # These are the same:
      # info: [
      #   :name,
      #   :email
      # ],
      info: %i[name email],
      # credentials: [
      #   :token
      # ]
      credentials: %i[token]
    )
  end
end
