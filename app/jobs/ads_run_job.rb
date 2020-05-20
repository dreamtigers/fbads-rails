class AdsRunJob < ApplicationJob
  queue_as :default

  # params: fb_ad
  # params: current_user
  def perform(fb_ad, current_user)

    pp ""
    pp "RUNNING ADSRUN JOB"
    pp ""

    hardcoded = {
      adset_name: 'Test',
      objective: 'CONVERSIONS',
      status: 'ACTIVE',
      call_to_action: "SHOP_NOW",
      age_min: 21,
      age_max: 45,
      budget: 10 # dollars
    }

    ad_creative = {
      name: "My Creative #{Random.rand(300)}",
      object_story_spec: {
        page_id: current_user.page_id,
        video_data: {
          video_id: fb_ad.video_id,
          image_url: fb_ad.thumbnail_url,
          title: fb_ad.headline,
          message: fb_ad.ptext,
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
      created_ad_creative = current_user.ad_acct_query.adcreatives.create(ad_creative)
    rescue FacebookAds::ClientError => e
      fb_ad.update({
        result_status: e.error_user_title
      })
      redirect_to fb_ads_path, alert: e.error_user_title
      return
    end

    campaign = {
      name: fb_ad.campaign_name,
      objective: hardcoded[:objective],
      special_ad_category: 'NONE',
      status: 'PAUSED',
    }

    begin
      created_campaign = current_user.ad_acct_query.campaigns.create(campaign)
    rescue FacebookAds::ClientError => e
      created_ad_creative.destroy
      fb_ad.update({
        result_status: e.error_user_title
      })
      redirect_to fb_ads_path, alert: e.error_user_title
      return
    end

    my_adsets = []
    my_ads = []
    my_errors = []

    # -07:00 == PST
    now = Time::now.getlocal('-07:00')
    if now.hour < 22
      start_date = Time.new(now.year, now.month, now.day + 1, 01, 00, 00, '-07:00')
    else
      start_date = Time.new(now.year, now.month, now.day + 2, 01, 00, 00, '-07:00')
    end

    targeting = {
      age_max: hardcoded[:age_max],
      age_min: hardcoded[:age_min],
      device_platforms: ['mobile', 'desktop'],
      facebook_positions: ['feed', 'video_feeds'],
      genders: [fb_ad.gender],
      geo_locations: {
        countries: fb_ad.countries,
        location_types: ['home', 'recent'],
      },
      instagram_positions: ['stream'],
      locales: [24,6],
      publisher_platforms: ['facebook', 'instagram'],
      targeting_optimization: 'none'
    }

    adset = {
      status: hardcoded[:status],
      start_time: start_date.iso8601,
      campaign_id: created_campaign.id,
      targeting: targeting,
      optimization_goal: 'OFFSITE_CONVERSIONS',
      billing_event: 'IMPRESSIONS',
      bid_strategy: 'LOWEST_COST_WITHOUT_CAP',
      lifetime_budget: hardcoded[:budget] * 100,
      # 60 seconds * 60 minutes * 24 hours * 7 days = 604800 seconds/week
      end_time: (start_date + 604800).iso8601,
      pacing_type: ['standard'],
      destination_type: 'WEBSITE',
      attribution_spec: [
        { event_type: 'CLICK_THROUGH', window_days: 7 },
        { event_type: 'VIEW_THROUGH', window_days: 1 }
      ],
      promoted_object: {
        pixel_id: fb_ad.pixel_id,
        custom_event_type: 'PURCHASE'
      }
    }

    (JSON.parse fb_ad.interests).each do |int|
      retrieved_adset = FacebookAds::AdsInterest.get(int, 'name', current_user.fb_session)
      adset[:name] = retrieved_adset.name
      adset[:targeting][:flexible_spec] = [ {
        interests: [{ id: int, name: retrieved_adset.name }]
      } ]

      begin
        created_adset = current_user.ad_acct_query.adsets.create(adset)
        pp ""
        pp created_adset
        pp ""
      rescue FacebookAds::ClientError => e
        my_errors.push(e.error_user_title)
        next
      end

      ad = {
        name: retrieved_adset.name,
        adset_id: created_adset.id,
        status: hardcoded[:status],
        creative: {
          creative_id: created_ad_creative.id
        },
        tracking_specs: [ {
            # We're using the old hash notation because symbols can't use `.`.
            "action.type" => ['offsite_conversion'],
            :fb_pixel => [fb_ad.pixel_id]
        } ]
      }

      begin
        created_ad = current_user.ad_acct_query.ads.create(ad)

        my_ads.push(created_ad.id)
        my_adsets.push(created_adset.id)
      rescue FacebookAds::ClientError => e
        my_errors.push(e.error_user_title)
        created_adset.destroy
      end
    end

    pp ""
    pp my_errors
    pp ""

    fb_ad.update({
      creative_id: created_ad_creative.id,
      campaign_id: created_campaign.id,
      ad_set_id: my_adsets,
      ad_id: my_ads,
      start_time: start_date,
      result: 1,
      result_status: my_errors
    })
  end
end
