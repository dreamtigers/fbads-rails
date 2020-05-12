class FbAdsController < ApplicationController
  before_action :require_login
  before_action :set_fb_ad, only: [:run]
  before_action :set_ad_acct_query, only: [:run]

  # GET /ads
  def index
    @fb_ads = FbAd.all
  end

  # # GET /ads/1
  # def show
  # end

  # GET /ads/new
  def new
    @fb_ad = FbAd.new
    # Should probably use something like: https://rubygems.org/gems/iso_3166
    @countries = [
      ["Australia",     "AU"], ["Austria",     "AT"], ["Belgium",        "BE"],
      ["Brazil",        "BR"], ["Canada",      "CA"], ["Croatia",        "HR"],
      ["Denmark",       "DK"], ["Estonia",     "EE"], ["Finland",        "FI"],
      ["France",        "FR"], ["Germany",     "DE"], ["Gibraltar",      "GI"],
      ["Great Britian", "GB"], ["Greece",      "GR"], ["Hong Kong",      "HK"],
      ["Hungary",       "HU"], ["Ireland",     "IE"], ["Israel",         "IL"],
      ["Italy",         "IT"], ["Japan",       "JP"], ["Latvia",         "LV"],
      ["Lithuania",     "LT"], ["Luxembourg",  "LU"], ["Malaysia",       "MY"],
      ["Malta",         "MT"], ["Mexico",      "MX"], ["Netherlands",    "NL"],
      ["New Zealand",   "NZ"], ["Norway",      "NO"], ["Poland",         "PL"],
      ["Portugal",      "PT"], ["Russia",      "RU"], ["Saudi Arabia",   "SA"],
      ["Singapore",     "SG"], ["Spain",       "ES"], ["South Korea",    "KR"],
      ["Sweden",        "SE"], ["Switzerland", "CH"], ["Thailand",       "TH"],
      ["Turkey",        "TR"], ["Ukraine",     "UA"], ["United Kingdom", "GB"],
      ["United States", "US"], ["Vietnam",     "VN"]
    ]
  end

  # # GET /ads/1/edit
  # def edit
  # end

  # POST /ads
  def create
    # Create and send the video to FB
    video = {
      name: "Video File #{Random.rand(300)}",
      file_url: fb_ad_params[:video_url]
    }
    created_video = current_user.ad_acct_query.advideos.create(video)

    # Create an empty FbAd a fill it with the form info
    @fb_ad = FbAd.new(fb_ad_params)

    # Add to the new FbUser the params that were not set in the form
    @fb_ad.uid = current_user.uid
    @fb_ad.video_id = created_video.id

    # TODO Allow the user to select the Pixel ID they want in the 'new' page
    @fb_ad.pixel_id = 2754542204668852

    # Time when to publish this ad
    # 60 seconds * 60 minutes * 24 hours = 86400 seconds/day
    tomorrow = Time::now + 86400
    @fb_ad.start_time = tomorrow

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
      pixelID: 2754542204668852,
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
    created_ad_creative = @ad_acct_query.adcreatives.create(ad_creative)

    campaign = {
      name: @fb_ad.campaign_name,
      objective: hardcoded[:objective],
      special_ad_category: 'NONE',
      status: 'PAUSED',
    }

    created_campaign = @ad_acct_query.campaigns.create(campaign)

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
      promoted_objects: {
        # TODO substitute with user's Pixel ID
        pixel_id: hardcoded[:pixelID],
        custom_event_type: 'PURCHASE'
      }
    }

    # TODO: Set the adset name and the interests
    adset[:name] = @fb_ad.interests

    pp adset

    created_ad_set = @ad_acct_query.ad_sets.create(adset)

    ad = {
      name: hardcoded[:adset_name],
      adset_id: created_ad_set.id,
      status: hardcoded[:status],
      creative: ad_creative,
      tracking_specs: [ {
          # We're using the old hash notation because symbols can't use `.`.
          "action.type" => 'offsite_conversion',
          # TODO substitute with user's Pixel ID
          :fb_pixel => [hardcoded[:pixelID]]
      } ]
    }

    respond_to do |format|
      begin
        created_ad = @ad_acct_query.ads.create(ad)
        @fb_ad.update({
          creative_id: created_ad_creative.id,
          campaign_id: created_campaign.id,
          ad_set_id: created_ad_set.id,
          ad_id: created_ad.id,
          start_time: Time::now.to_i,
          result: 1,
        })
        format.html { redirect_to @fb_ad, notice: 'Fb ad was successfully created.' }
      rescue FacebookAds::ClientError => e
        format.html { render :new, alert: e.error_user_title }
      end
    end

    # begin
    #   created_ad = @ad_acct_query.ads.create(ad)
    # rescue FacebookAds::ClientError => e
    #   if e.error_user_title.include? 'Payment Method Is Missing'
    #     alert: e.error_user_title
    #   elsif e.error_user_title.include? 'Video'
    #     alert: "please wait a while while facebook creates the video"
    #   end
    # end

    # redirect_to root_path, notice: "Ad Campaign: #{!created_campaign.nil?}\nAd Set: #{!created_ad_set.nil?}\nAd: #{!created_ad.nil?}"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fb_ad
      @fb_ad = FbAd.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def fb_ad_params
      params.require(:fb_ad).permit(:campaign_name, :interests, :gender, :headline, :ptext, :video_url, :thumbnail_url, :pixel_id, :video_url, :countries => [])
    end

    # Handy function
    def set_ad_acct_query
      # @ad_acct_query = FacebookAds::AdAccount.get(current_user.ad_account_id, 'name', current_user.fb_session)
      @ad_acct_query = current_user.ad_acct_query
    end
end
