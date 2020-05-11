require 'test_helper'

class FbAdsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @fb_ad = fb_ads(:one)
  end

  test "should get index" do
    get fb_ads_url
    assert_response :success
  end

  test "should get new" do
    get new_fb_ad_url
    assert_response :success
  end

  test "should create fb_ad" do
    assert_difference('FbAd.count') do
      post fb_ads_url, params: { fb_ad: { campaign_name: @fb_ad.campaign_name, countries: @fb_ad.countries, gender: @fb_ad.gender, headline: @fb_ad.headline, interests: @fb_ad.interests, pixel_id: @fb_ad.pixel_id, ptext: @fb_ad.ptext, start_time: @fb_ad.start_time, thumbnail_url: @fb_ad.thumbnail_url, uid: @fb_ad.uid, video_id: @fb_ad.video_id, video_url: @fb_ad.video_url } }
    end

    assert_redirected_to fb_ad_url(FbAd.last)
  end

  test "should show fb_ad" do
    get fb_ad_url(@fb_ad)
    assert_response :success
  end

  test "should get edit" do
    get edit_fb_ad_url(@fb_ad)
    assert_response :success
  end

  test "should update fb_ad" do
    patch fb_ad_url(@fb_ad), params: { fb_ad: { campaign_name: @fb_ad.campaign_name, countries: @fb_ad.countries, gender: @fb_ad.gender, headline: @fb_ad.headline, interests: @fb_ad.interests, pixel_id: @fb_ad.pixel_id, ptext: @fb_ad.ptext, start_time: @fb_ad.start_time, thumbnail_url: @fb_ad.thumbnail_url, uid: @fb_ad.uid, video_id: @fb_ad.video_id, video_url: @fb_ad.video_url } }
    assert_redirected_to fb_ad_url(@fb_ad)
  end

  test "should destroy fb_ad" do
    assert_difference('FbAd.count', -1) do
      delete fb_ad_url(@fb_ad)
    end

    assert_redirected_to fb_ads_url
  end
end
