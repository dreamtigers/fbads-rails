class FbUser < ApplicationRecord
  def self.from_omniauth(auth)
    where(uid: auth.uid).first_or_initialize.tap do |user|
      user.uid = auth.uid
      user.name = auth.info.name
      user.email = auth.info.email
      user.token = auth.credentials.token
      # user.adaccount =
      # user.pageID =
      # user.url =
      user.active = 1
      user.save!
    end
  end
end
