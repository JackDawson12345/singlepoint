class WebsitesCustomisation < ApplicationRecord
  belongs_to :website, optional: true # Adjust based on your setup
  belongs_to :component

  validates :field_name, presence: true
  validates :field_value, presence: true
  validates :component_id, presence: true

  validates :field_name, uniqueness: {
    scope: [:website_id, :component_id, :theme_page_id],
    message: "already exists for this component"
  }
end
