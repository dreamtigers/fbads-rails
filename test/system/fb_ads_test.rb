require "application_system_test_case"

class FbAdsTest < ApplicationSystemTestCase
  setup do
    @fb_ad = fb_ads(:one)
  end

  test "visiting the index" do
    visit fb_ads_url
    assert_selector "h1", text: "Fb Ads"
  end

  test "creating a Fb ad" do
    visit fb_ads_url
    click_on "New Fb Ad"

    fill_in "Campaign name", with: @fb_ad.campaign_name
    fill_in "Countries", with: @fb_ad.countries
    fill_in "Gender", with: @fb_ad.gender
    fill_in "Headline", with: @fb_ad.headline
    fill_in "Interests", with: @fb_ad.interests
    fill_in "Pixel", with: @fb_ad.pixel_id
    fill_in "Ptext", with: @fb_ad.ptext
    fill_in "Start time", with: @fb_ad.start_time
    fill_in "Thumbnail url", with: @fb_ad.thumbnail_url
    fill_in "Uid", with: @fb_ad.uid
    fill_in "Video", with: @fb_ad.video_id
    fill_in "Video url", with: @fb_ad.video_url
    click_on "Create Fb ad"

    assert_text "Fb ad was successfully created"
    click_on "Back"
  end

  test "updating a Fb ad" do
    visit fb_ads_url
    click_on "Edit", match: :first

    fill_in "Campaign name", with: @fb_ad.campaign_name
    fill_in "Countries", with: @fb_ad.countries
    fill_in "Gender", with: @fb_ad.gender
    fill_in "Headline", with: @fb_ad.headline
    fill_in "Interests", with: @fb_ad.interests
    fill_in "Pixel", with: @fb_ad.pixel_id
    fill_in "Ptext", with: @fb_ad.ptext
    fill_in "Start time", with: @fb_ad.start_time
    fill_in "Thumbnail url", with: @fb_ad.thumbnail_url
    fill_in "Uid", with: @fb_ad.uid
    fill_in "Video", with: @fb_ad.video_id
    fill_in "Video url", with: @fb_ad.video_url
    click_on "Update Fb ad"

    assert_text "Fb ad was successfully updated"
    click_on "Back"
  end

  test "destroying a Fb ad" do
    visit fb_ads_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Fb ad was successfully destroyed"
  end
end
