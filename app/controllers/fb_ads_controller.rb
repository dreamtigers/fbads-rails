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

    # Time when to publish this ad
    # 60 seconds * 60 minutes * 24 hours = 86400 seconds/day
    @fb_ad.uid = current_user.uid
    tomorrow = Time::now + 86400
    @fb_ad.start_time = tomorrow

    # Create and send the video to FB
    video = {
      name: "Video File #{Random.rand(300)}",
      file_url: fb_ad_params[:video_url]
    }

    begin
      created_video = current_user.ad_acct_query.advideos.create(video)
    rescue FacebookAds::ClientError => e
      flash.now[:alert] = e.error_user_title
      render :new
      return
    end

    # Add to the new FbUser the params that were not set in the form
    @fb_ad.video_id = created_video.id

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
    hardcoded = {
      adset_name: 'Test',
      objective: 'CONVERSIONS',
      status: 'ACTIVE',
      call_to_action: "SHOP_NOW",
      age_min: 21,
      age_max: 45,
      daily_budget: 10 # dollars
    }

    ad_creative = {
      name: "My Creative #{Random.rand(300)}",
      object_story_spec: {
        page_id: current_user.page_id,
        video_data: {
          video_id: @fb_ad.video_id,
          image_url: @fb_ad.thumbnail_url,
          title: @fb_ad.headline,
          message: @fb_ad.ptext,
          call_to_action: {
            type: hardcoded[:call_to_action],
            value: {
              link: current_user.url
            }
          }
        }
      }
    }
    begin
      created_ad_creative = @ad_acct_query.adcreatives.create(ad_creative)
    rescue FacebookAds::ClientError => e
      @fb_ad.update({
        result_status: e.error_user_title
      })
      redirect_to fb_ads_path, alert: e.error_user_title
      return
    end

    campaign = {
      name: @fb_ad.campaign_name,
      objective: hardcoded[:objective],
      special_ad_category: 'NONE',
      status: 'PAUSED',
    }

    begin
      created_campaign = @ad_acct_query.campaigns.create(campaign)
    rescue FacebookAds::ClientError => e
      created_ad_creative.destroy
      @fb_ad.update({
        result_status: e.error_user_title
      })
      redirect_to fb_ads_path, alert: e.error_user_title
      return
    end

    my_adsets = []
    my_ads = []

    my_errors = []

    targeting = {
      age_max: hardcoded[:age_max],
      age_min: hardcoded[:age_min],
      device_platforms: ['mobile', 'desktop'],
      facebook_positions: ['feed', 'video_feeds'],
      genders: [@fb_ad.gender],
      geo_locations: {
        countries: @fb_ad.countries,
        location_types: ['home', 'recent'],
      },
      instagram_positions: ['stream'],
      locales: [24,6],
      publisher_platforms: ['facebook', 'instagram'],
      targeting_optimization: 'none'
    }

    adset = {
      status: hardcoded[:status],
      start_time: @fb_ad.start_time,
      campaign_id: created_campaign.id,
      targeting: targeting,
      optimization_goal: 'OFFSITE_CONVERSIONS',
      billing_event: 'IMPRESSIONS',
      bid_strategy: 'LOWEST_COST_WITHOUT_CAP',
      daily_budget: hardcoded[:daily_budget] * 100,
      pacing_type: ['standard'],
      destination_type: 'WEBSITE',
      attribution_spec: [
        { event_type: 'CLICK_THROUGH', window_days: 7 },
        { event_type: 'VIEW_THROUGH', window_days: 1 }
      ],
      promoted_object: {
        pixel_id: @fb_ad.pixel_id,
        custom_event_type: 'PURCHASE'
      }
    }

    interests = (JSON.parse @fb_ad.interests).each do |int|
      adset_name = FacebookAds::AdsInterest.get(int, 'name', current_user.fb_session)
      adset[:name] = adset_name
      adset[:targeting][:flexible_spec] = {
        interests: { id: int, name: adset_name }
      }

      begin
        created_adset = @ad_acct_query.adsets.create(adset)
      rescue FacebookAds::ClientError => e
        my_errors.push(e)
        next
      end

      ad = {
        name: hardcoded[:adset_name],
        adset_id: created_adset.id,
        status: hardcoded[:status],
        creative: created_ad_creative.id,
        tracking_specs: [ {
            # We're using the old hash notation because symbols can't use `.`.
            "action.type" => 'offsite_conversion',
            :fb_pixel => [@fb_ad.pixel_id]
        } ]
      }

      begin
        created_ad = @ad_acct_query.ads.create(ad)
        pp created_ad

        my_ads.push(created_ad.id)
        my_adsets.push(created_adset.id)
      rescue FacebookAds::ClientError => e
        my_errors.push(e)
        created_adset.destroy
      end
    end

    @fb_ad.update({
      creative_id: created_ad_creative.id,
      campaign_id: created_campaign.id,
      ad_set_id: my_adsets,
      ad_id: my_ads,
      start_time: Time::now.to_i,
      result: 1,
    })

    respond_to do |format|
      if my_errors.empty?
        format.html { redirect_to fb_ads_path, notice: 'Fb ad was successfully created.' }
      else
        format.html { redirect_to fb_ads_path, alert: e.error_user_title }
      end
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
