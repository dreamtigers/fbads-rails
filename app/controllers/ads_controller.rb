class AdsController < ApplicationController
  before_action :require_login

  def index
    @ads = current_user.ad_acct_query.ads(fields: 'name').map(&:name)
  end

  def create
    hardcoded = {
      adset_name: 'Test',
      objective: 'CONVERSIONS',
      pixelID: 12345,
      status: 'ACTIVE'
    }

    # ad_creative = {
    #   name: "My Creative #{Random.rand(300)}",
    #   object_story_spec: {
    #     link_data: {
    #       attachment_style: 'link',
    #       call_to_action: {
    #         type: 'SHOP_NOW'
    #       },
    #       description: params[:description],
    #       link: current_user.url,
    #       message: params[:message],
    #       name: params[:headline],
    #       # This is a URL of a picture to use in the post.
    #       picture: image,
    #     },
    #     page_id: current_user.pageID
    #   }
    # }
    # created_ad_creative = current_user.ad_acct_query.adcreatives.create(ad_creative)

    campaign = {
      name: params[:campaign_name],
      objective: hardcoded[:objective],
      special_ad_category: 'NONE',
      status: 'PAUSED',
    }

    created_campaign = current_user.ad_acct_query.campaigns.create(campaign)

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

    created_ad_set = current_user.ad_acct_query.ad_sets.create(adset)

    ad = {
      name: hardcoded[:adset_name],
      adset_id: created_ad_set.id,
      status: hardcoded[:status],
      creative: {
        # NOTE: Again, apparently the creative_id comes from `fb_ads`. But
        # since I don't have it, I can't do much about it. TODO
        # creative_id: created_ad_creative.id
        creative_id: 1
      }
    }

    if hardcoded[:pixelID] != nil
      ad[:tracking_specs] = [
        # We're using the old hash notation because symbols can't use `.`.
        {
          "action.type" => 'offsite_conversion',
          :fb_pixel => [hardcoded[:pixelID]]
        }
      ]
    end

    created_ad = current_user.ad_acct_query.ads.create(ad)

    pp created_ad
    byebug
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
end
