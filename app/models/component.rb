class Component < ApplicationRecord
  has_many :theme_page_components, dependent: :destroy

  # Admin Theme Page Preview
  def rendered_html_content(theme = nil, current_user = nil)
    return html_content unless html_content.present?

    content = html_content.dup

    # Handle editable_fields if present
    if editable_fields.present?
      begin
        fields_hash = JSON.parse(editable_fields)
        fields_hash.each do |key, value|
          content.gsub!("{{#{key}}}", value.to_s)
        end
      rescue JSON::ParserError => e
        Rails.logger.error "Failed to parse editable_fields: #{e.message}"
      end
    end

    # Handle special nav_items replacement
    if content.include?('{{nav_items}}') && theme.present?
      nav_items_html = generate_nav_items(theme, current_user)
      content.gsub!('{{nav_items}}', nav_items_html)
    end

    content
  end

  def rendered_manage_html_content(theme = nil, current_user = nil, theme_page = nil, component = nil)
    return html_content unless html_content.present?

    content = html_content.dup

    # Handle editable_fields if present
    if editable_fields.present?
      begin
        fields_hash = JSON.parse(editable_fields)
        fields_hash.each do |key, value|
          websiteCustomisation = WebsitesCustomisation.where(website_id: current_user.website.id, component_id: component.id, theme_page_id: theme_page.id, field_name: key)

          if websiteCustomisation.blank?
            content.gsub!("{{#{key}}}", value.to_s)
          else
            content.gsub!("{{#{key}}}", websiteCustomisation.first.field_value)
          end

        end
      rescue JSON::ParserError => e
        Rails.logger.error "Failed to parse editable_fields: #{e.message}"
      end
    end

    # Handle special nav_items replacement
    if content.include?('{{nav_items}}') && theme.present?
      nav_items_html = generate_nav_items(theme, current_user)
      content.gsub!('{{nav_items}}', nav_items_html)
    elsif content.include?('{{services}}') && theme.present?
      services_html = generate_service_items(theme, current_user)
      content.gsub!('{{services}}', services_html)
    end

    content
  end

  def rendered_manage_service_inner_html_content(theme = nil, current_user = nil, theme_page = nil, component = nil, service = nil)
    return html_content unless html_content.present?

    content = html_content.dup


    # Handle nav_items replacement
    if content.include?('{{nav_items}}') && theme.present?
      nav_items_html = generate_nav_items(theme, current_user)
      content.gsub!('{{nav_items}}', nav_items_html)
    end

    # Handle single service title replacement
    if content.include?('{{single_service_title}}') && theme.present? && service.present?
      byebug
      content.gsub!('{{single_service_title}}', service.title)
    end

    content
  end

  private
  # Admin Theme Page Preview Navbar
  def generate_nav_items(theme, current_user = nil)
    return '' unless theme&.theme_pages&.any?

    nav_template = get_nav_item_template

    theme.theme_pages.map do |theme_page|
      item_html = nav_template.dup

      # Replace nav_item with page_type
      item_html.gsub!('{{nav_item}}', theme_page.page_type)

      # Replace nav_item_link based on user role
      if current_user&.role == 0
        link = Rails.application.routes.url_helpers.admin_theme_pages_preview_path(
          id: theme.id,
          theme_page_id: theme_page.id
        )
      else
        link = theme_page.slug
      end

      item_html.gsub!('{{nav_item_link}}', link)
      item_html
    end.join("\n")
  end
  # Admin Theme Page Preview Navbar
  def get_nav_item_template
    return '' unless template_patterns.present?

    begin
      patterns_hash = JSON.parse(template_patterns)
      patterns_hash['nav_items'] || ''
    rescue JSON::ParserError => e
      Rails.logger.error "Failed to parse template_patterns: #{e.message}"
      ''
    end
  end

  def generate_service_items(theme, current_user = nil)
    return '' unless theme&.theme_pages&.any?

    service_template = get_service_item_template


    current_user.website_services.map do |service|
      item_html = service_template.dup

      # Replace nav_item with page_type
      item_html.gsub!('{{service_title}}', service.title)
      item_html.gsub!('{{service_text}}', service.text.truncate(200))

      item_html.gsub!('{{service_feature_one}}', service.features.to_a[0][1])
      item_html.gsub!('{{service_feature_two}}', service.features.to_a[1][1])
      item_html.gsub!('{{service_feature_three}}', service.features.to_a[2][1])
      item_html.gsub!('{{service_feature_four}}', service.features.to_a[3][1])

      item_html.gsub!('{{service_icon}}', service.icon)




      item_html
    end.join("\n")
  end

  def get_service_item_template
    return '' unless template_patterns.present?

    begin
      patterns_hash = JSON.parse(template_patterns)
      patterns_hash['services'] || ''
    rescue JSON::ParserError => e
      Rails.logger.error "Failed to parse template_patterns: #{e.message}"
      ''
    end
  end

end