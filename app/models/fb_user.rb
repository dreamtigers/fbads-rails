class FbUser < ApplicationRecord

  # When you find a FbUser, call the fb_ad_account setter to instantiate an
  # ad_account.
  after_find :fb_ad_account=

  # A class method uses self to distinguish from instance methods.
  # It can only be called on the class, not an instance.
  def self.from_omniauth(auth)
    where(uid: auth.uid).first_or_initialize.tap do |user|
      user.uid = auth.uid
      user.name = auth.info.name
      user.email = auth.info.email
      user.token = auth.credentials.token

      # Get the ad account info of our user
      ad_account_info = graph_get(fb_query('me/adaccounts?fields=account_id,account_status', user.token))
      # So we can save the ad account id
      user.adaccount = ad_account_info['data'][0]['id']

      # user.pageID =
      # user.url =
      user.active = 1
      user.save!
    end
  end

  # Setter
  def fb_ad_account=
    # The app_secret and api version are already set in the initializer
    # We set up the session per user, that's the reason for this method.
    session = FacebookAds::Session.new(access_token: self.token)
    @fb_ad_account = FacebookAds::AdAccount.get(self.adaccount, 'name', session)
  end

  # Getter
  attr_reader :fb_ad_account

  private

  def self.fb_query(uri, token)
    return URI("https://graph.facebook.com/v6.0/#{uri}&access_token=#{token}")
  end

  def self.graph_get(query)
    JSON.parse(Net::HTTP.get(query))
  end
end
