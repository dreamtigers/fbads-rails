require 'test_helper'

class AdsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get ads_index_url
    assert_response :success
  end

  test "should get create" do
    get ads_create_url
    assert_response :success
  end

  test "should get new" do
    get ads_new_url
    assert_response :success
  end

end
