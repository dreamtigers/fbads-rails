class AdsController < ApplicationController
  before_action :require_login
  before_action :set_ad_acct_query, only: [:index, :create]

  def index
    fields = 'name'
    @ads = @ad_acct_query.ads(fields: fields).all
  end

  def create
    hardcoded = {
      adset_name: 'Test',
      objective: 'CONVERSIONS',
      pixelID: 2754542204668852,
      status: 'ACTIVE'
    }

    # video = {
    #   name: "Video File #{Random.rand(300)}",
    #   file_url: params[:videoURL]
    # }

    # created_video = @ad_acct_query.advideos.create(video)

    ad_creative = {
      name: "My Creative #{Random.rand(300)}",
      object_story_spec: {
        link_data: {
          picture: 'https://bulma.io/images/placeholders/720x240.png',
          link: current_user.url,
          message: params[:message],
        },
        page_id: current_user.pageID
      }
    }
    created_ad_creative = @ad_acct_query.adcreatives.create(ad_creative)

    # ad_creative = {
    #   name: "My Creative #{Random.rand(300)}",
    #   object_story_spec: {
    #     page_id: current_user.pageID,
    #     video_data: {
    #       video_id: created_video.id,
    #       image_url: 'https://bulma.io/images/placeholders/720x240.png',
    #       title: params[:headline],
    #       message: params[:message],
    #       call_to_action: {
    #         type: 'SHOP_NOW',
    #         value: {
    #           link: current_user.url
    #         }
    #       }
    #     }
    #   }
    # }
    # created_ad_creative = @ad_acct_query.adcreatives.create(ad_creative)

    campaign = {
      name: params[:campaign_name],
      objective: hardcoded[:objective],
      special_ad_category: 'NONE',
      status: 'PAUSED',
    }

    created_campaign = @ad_acct_query.campaigns.create(campaign)

    targeting = {
      age_max: 45,
      age_min: 21,
      device_platforms: ['mobile', 'desktop'],
      facebook_positions: ['feed', 'video_feeds'],
      genders: [params[:gender]],
      geo_locations: {
        countries: params[:countries],
        location_types: ['home'],
      },
      instagram_positions: ['stream'],
      locales: [24,6],
      publisher_platforms: ['facebook', 'instagram'],
      # targeting_optimization: 'none'
    }

    adset = {
      bid_strategy: 'LOWEST_COST_WITHOUT_CAP',
      billing_event: 'IMPRESSIONS',
      campaign_id: created_campaign.id,
      daily_budget: 10000,
      destination_type: 'WEBSITE',
      name: hardcoded[:adset_name],
      optimization_goal: 'OFFSITE_CONVERSIONS',
      pacing_type: ['standard'],
      # NOTE: Apparently the start_time is fetched from the database, from the
      # table `fb_ads`. Since I lack said table, I'll be using the current
      # time. TODO
      start_time: Time::now.to_i,
      status: hardcoded[:status],
      targeting: targeting,
    }

    if hardcoded[:objective] == 'CONVERSIONS'
      adset[:promoted_object] = {
        pixel_id: hardcoded[:pixelID],
        custom_event_type: 'PURCHASE'
      }
    end

    begin
      created_ad_set = @ad_acct_query.ad_sets.create(adset)
    rescue
      created_campaign = false
    end

    ad = {
      name: hardcoded[:adset_name],
      adset_id: created_ad_set.id,
      status: hardcoded[:status],
      creative: ad_creative
    }

    if hardcoded[:pixelID] != nil
      ad[:tracking_specs] = [ {
          # We're using the old hash notation because symbols can't use `.`.
          "action.type" => 'offsite_conversion',
          :fb_pixel => [hardcoded[:pixelID]]
        } ]
    end

    begin
      created_ad = @ad_acct_query.ads.create(ad)
    rescue
      created_campaign = false
    end

    # pp created_ad
    redirect_to root_path, notice: "Ad Campaign: #{!created_campaign.nil?}\nAd Set: #{!created_ad_set.nil?}\nAd: #{!created_ad.nil?}"
  end

  def new
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

  private

  def set_ad_acct_query
    # @ad_acct_query = FacebookAds::AdAccount.get(current_user.adaccount, 'name', current_user.fb_session)
    @ad_acct_query = current_user.ad_acct_query
  end

end
