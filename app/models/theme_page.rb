class ThemePage < ApplicationRecord
  belongs_to :theme
  has_many :theme_page_components, dependent: :destroy
end
