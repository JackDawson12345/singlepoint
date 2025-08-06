class WebsiteService < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, length: { minimum: 2, maximum: 255 }
  validates :text, presence: true, length: { minimum: 10 }
  validates :icon, presence: true
  validates :features, presence: true

  # Ensure features is always a hash
  def features
    super || {}
  end
end
