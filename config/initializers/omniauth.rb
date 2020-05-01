OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, Rails.application.credentials.fb_app[:id], Rails.application.credentials.fb_app[:secret]
end
