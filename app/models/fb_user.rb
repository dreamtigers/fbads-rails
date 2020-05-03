class FbUser < ApplicationRecord

  # When you find a FbUser, call the ad_acct_query setter to instantiate an
  # ad_account.
  after_find :ad_acct_query=
  after_find :fb_session=

  # A class method uses self to distinguish from instance methods.
  # It can only be called on the class, not an instance.
  def self.from_omniauth(auth)
    where(uid: auth.uid).first_or_initialize.tap do |user|
      user.uid = auth.uid
      user.name = auth.info.name
      user.email = auth.info.email
      user.token = auth.credentials.token

      # user_query = FacebookAds::User.get(id, @session)
      # ad_account_info
      # Get the ad account info of our user
      ad_account_info = graph_get(fb_query('me/adaccounts?fields=account_id,account_status', user.token))
      # So we can save the ad account id
      user.adaccount = ad_account_info['data'][0]['id']

      pages_info = graph_get(fb_query('me/accounts?limit=100', user.token))
      user.pageID = pages_info['data'][0]['id']
      # user.url =
      user.active = 1
      user.save!
    end
  end

  # Setter
  def ad_acct_query=
    # The app_secret and api version are already set in the initializer
    # We set up the session per user, that's the reason for this method.
    @ad_acct_query = FacebookAds::AdAccount.get(self.adaccount, 'name', @session)
  end
  # Getter
  attr_reader :ad_acct_query

  # Setter
  def fb_session=
    @fb_session = FacebookAds::Session.new(access_token: self.token)
  end
  # Getter
  attr_reader :fb_session

  private

  def self.fb_query(uri, token)
    return URI("https://graph.facebook.com/v6.0/#{uri}&access_token=#{token}")
  end

  def self.graph_get(query)
    JSON.parse(Net::HTTP.get(query))
  end
end
