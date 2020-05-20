class FbAdsController < ApplicationController
  before_action :require_login
  before_action :set_fb_ad, only: [:run]
  before_action :set_ad_acct_query, only: [:run, :update_interests]

  # GET /ads
  def index
    @fb_ads = FbAd.where(uid: current_user.uid)
  end

  # # GET /ads/1
  # def show
  # end

  # GET /ads/new
  def new
    @fb_ad = FbAd.new
  end

  # # GET /ads/1/edit
  # def edit
  # end

  def update_interests
    @interests = @ad_acct_query.targetingsearch({
      q: params[:suggestion],
      type: 'adinterest',
      fields: 'name,id,audience_size'
    }).first(10)

    render json: @interests
  end

  # POST /ads
  def create
    # Create an empty FbAd a fill it with the form info
    @fb_ad = FbAd.new(fb_ad_params)

    @fb_ad.uid = current_user.uid
    # Time when to publish this ad.
    # NOTE this is a tentative date, from the original code. When this ad is
    # 'run' (see fb_ads#run) it will update the start_time.
    # 60 seconds * 60 minutes * 24 hours = 86400 seconds/day
    tomorrow = Time::now + 86400
    @fb_ad.start_time = tomorrow

    # Create and send the video to FB
    video = {
      name: "Video File #{Random.rand(300)}",
      file_url: fb_ad_params[:video_url]
    }

    begin
      created_video = current_user.ad_acct_query.advideos.create(video)

      # Add to the new FbUser the params that were not set in the form
      @fb_ad.video_id = created_video.id
    rescue FacebookAds::ClientError => e
      flash.now[:alert] = e.error_user_title
      render :new
      return
    end

    respond_to do |format|
      if @fb_ad.save
        format.html { redirect_to fb_ads_url, notice: 'Fb ad was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # # PATCH/PUT /ads/1
  # def update
  #   respond_to do |format|
  #     if @fb_ad.update(fb_ad_params)
  #       format.html { redirect_to @fb_ad, notice: 'Fb ad was successfully updated.' }
  #       format.json { render :show, status: :ok, location: @fb_ad }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @fb_ad.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # DELETE /ads/1
  # def destroy
  #   @fb_ad.destroy
  #   respond_to do |format|
  #     format.html { redirect_to fb_ads_url, notice: 'Fb ad was successfully destroyed.' }
  #     format.json { head :no_content }
  #   end
  # end

  # POST /ads/1/run
  def run


    AdsRunJob.perform_later @fb_ad, current_user

    @fb_ad.update({
      result_status: 'Pending.'
    })

    respond_to do |format|
      format.html { redirect_to fb_ads_path, notice: 'Fb ad is pending to be created.' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fb_ad
      @fb_ad = FbAd.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def fb_ad_params
      params[:fb_ad][:countries] = params[:fb_ad][:countries].reject {|c| c.empty?}
      params[:fb_ad][:interests] = params[:fb_ad][:interests].reject {|c| c.empty?}
      params.require(:fb_ad).permit(:campaign_name, :gender, :headline, :ptext,
                                    :video_url, :thumbnail_url, :pixel_id,
                                    :interests => [], :countries => [])
    end

    # Handy function
    def set_ad_acct_query
      # @ad_acct_query = FacebookAds::AdAccount.get(current_user.ad_account_id, 'name', current_user.fb_session)
      @ad_acct_query = current_user.ad_acct_query
    end
end
