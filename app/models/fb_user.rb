class FbUser < ApplicationRecord
  after_find :fb_session=
  after_find :ad_acct_query=
  after_find :u_query=

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

      user.ad_account_id = user_query.adaccounts.first.id
      user.page_id = user_query.accounts.first.id

      # user.url =
      user.active = 1
      user.save!
    end
  end


  # ###################
  # Facebook ad account
  # ###################

  # Setter
  def ad_acct_query=
    # The app_secret and api version are already set in the initializer
    # We set up the session per user, that's the reason for this method.
    # session = FacebookAds::Session.new(access_token: self.token)
    @ad_acct_query = FacebookAds::AdAccount.get(self.ad_account_id, 'name', fb_session)
  end
  # Getter
  attr_reader :ad_acct_query


  # #############
  # Facebook user
  # #############

  # Setter
  def u_query=
    # The app_secret and api version are already set in the initializer
    # We set up the session per user, that's the reason for this method.
    # session = FacebookAds::Session.new(access_token: self.token)
    @u_query = FacebookAds::User.get(self.uid, fb_session)
  end
  # Getter
  attr_reader :u_query


  # ################
  # Facebook session
  # ################

  # Setter
  def fb_session=
    @fb_session = FacebookAds::Session.new(access_token: self.token)
  end
  # Getter
  attr_reader :fb_session

end
