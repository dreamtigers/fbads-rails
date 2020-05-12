class HomeController < ApplicationController
  before_action :require_login, only: [:edit, :update]
  before_action :set_fb_user, only: [:edit, :update]

  def index
  end

  # GET /edit
  def edit
    @ad_accounts = @fb_user.u_query.adaccounts(fields: 'name,id').map {|a| [a.name, a.id]}
    @pages = @fb_user.u_query.accounts(fields: 'name,id').map {|p| [p.name, p.id]}
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
    params.require(:fb_user).permit(:ad_account_id, :page_id, :url)
  end

end
