class Website < ApplicationRecord
  belongs_to :user
  belongs_to :theme

  def total_pages_count
    theme.theme_pages.count
  end

  def total_components_count
    theme.theme_pages.joins(:theme_page_components).count('theme_page_components.id')
  end

  def total_editable_fields
    components = Component.joins(theme_page_components: { theme_page: :theme })
                          .where(themes: { id: self.theme_id })

    Rails.logger.debug "Found #{components.count} components"

    total = 0
    components.each do |component|
      Rails.logger.debug "Component #{component.id}: #{component.editable_fields}"

      if component.editable_fields.present?
        begin
          fields_hash = JSON.parse(component.editable_fields)
          field_count = fields_hash.keys.count
          total += field_count
          Rails.logger.debug "Added #{field_count} fields, total now: #{total}"
        rescue JSON::ParserError => e
          Rails.logger.debug "JSON parse error: #{e.message}"
        end
      else
        Rails.logger.debug "No editable_fields for component #{component.id}"
      end
    end

    total
  end

  def formatted_updated_at
    return "Just now" if updated_at > 1.hour.ago

    time_diff = Time.current - updated_at

    if time_diff < 24.hours
      hours = (time_diff / 1.hour).floor
      hours == 1 ? "1 hour ago" : "#{hours} hours ago"
    elsif time_diff <= 7.days
      days = (time_diff / 1.day).floor
      days == 1 ? "1 day ago" : "#{days} days ago"
    else
      "7+ days ago"
    end
  end
end