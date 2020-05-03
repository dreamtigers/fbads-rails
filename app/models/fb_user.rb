class FbUser < ApplicationRecord

  def self.from_omniauth(auth)
    where(uid: auth.uid).first_or_initialize.tap do |user|
      user.uid = auth.uid
      user.name = auth.info.name
      user.email = auth.info.email
      user.token = auth.credentials.token

      ad_account = graph_get(fb_query('me/adaccounts?fields=account_id,account_status', user.token))

      user.adaccount = ad_account['data'][0]['id']

      # user.pageID =
      # user.url =
      user.active = 1
      user.save!
    end
  end

  # def self.fb_session
  # end

  private

  def self.fb_query(uri, token)
    return URI("https://graph.facebook.com/v6.0/#{uri}&access_token=#{token}")
  end

  def self.graph_get(query)
    JSON.parse(Net::HTTP.get(query))
  end
end
