OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  # provider :facebook, Rails.application.credentials.fb_app[:id],
  #          Rails.application.credentials.fb_app[:secret],
  provider :facebook, ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'],
           scope: 'email,manage_pages,ads_management',
           client_options: {
             site: 'https://graph.facebook.com/v6.0',
             authorize_url: "https://www.facebook.com/v6.0/dialog/oauth"
           }
end
