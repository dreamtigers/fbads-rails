class FbUser < ApplicationRecord

  after_find :fb_session=
  after_find :ad_acct_query=

  # A class method uses self to distinguish from instance methods.
  # It can only be called on the class, not an instance.
  def self.from_omniauth(auth)
    where(uid: auth.uid).first_or_initialize.tap do |user|
      user.uid = auth.uid
      user.name = auth.info.name
      user.email = auth.info.email
      user.token = auth.credentials.token

      session = FacebookAds::Session.new(access_token: user.token)
      user_query = FacebookAds::User.get(user.uid, session)
      user.adaccount = user_query.adaccounts.first.id
      user.pageID = user_query.accounts.first.id

      # user.url =
      user.active = 1
      user.save!
    end
  end

  # Setter
  def ad_acct_query=
    # The app_secret and api version are already set in the initializer
    # We set up the session per user, that's the reason for this method.
    session = FacebookAds::Session.new(access_token: self.token)
    @ad_acct_query = FacebookAds::AdAccount.get(self.adaccount, 'name', session)
  end
  # Getter
  attr_reader :ad_acct_query

  # Setter
  def fb_session=
    @fb_session = FacebookAds::Session.new(access_token: self.token)
  end
  # Getter
  attr_reader :fb_session

end
