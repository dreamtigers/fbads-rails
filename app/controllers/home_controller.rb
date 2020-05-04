class HomeController < ApplicationController
  before_action :require_login, only: [:edit, :update]
  before_action :set_fb_user, only: [:edit, :update]

  def index
  end

  # GET /edit
  def edit
    user_query = FacebookAds::User.get(@fb_user.uid, @fb_user.fb_session)
    @ad_accounts = user_query.adaccounts(fields: 'name,account_id').map {|a| [a.name, a.account_id]}
    @pages = user_query.accounts(fields: 'name,id').map {|p| [p.name, p.id]}
  end

  # PATCH/PUT /edit
  def update
    respond_to do |format|
      if @fb_user.update(fb_user_params)
        format.html { redirect_to root_path, notice: 'User was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  def privacy
  end

  private

  def set_fb_user
    @fb_user = FbUser.find(session[:user_id])
  end

  def fb_user_params
    params.require(:fb_user).permit(:adaccount, :pageID, :url)
  end

end
