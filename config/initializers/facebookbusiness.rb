FacebookAds.configure do |config|
  config.api_version = 'v6.0'
  config.app_secret = Rails.application.credentials.fb_app[:secret]
end
