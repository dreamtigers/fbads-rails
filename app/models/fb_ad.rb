class FbAd < ApplicationRecord
  validates :uid, presence: true
  validates :campaign_name, presence: true
  validates :interests, presence: true
  validates :gender, presence: true
  validates :headline, presence: true
  validates :ptext, presence: true
  validates :video_url, presence: true
  validates :thumbnail_url, presence: true
  validates :pixel_id, presence: true
  validates :countries, presence: true, length: { minimum: 4, too_short: ": select at least one." }
end
