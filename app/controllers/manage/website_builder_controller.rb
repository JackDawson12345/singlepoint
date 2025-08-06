class Manage::WebsiteBuilderController < ApplicationController
  before_action :authenticate_user!
  before_action :account_setup?
  layout 'manage', except: [:editor]

  def index
  end

  def editor
    @user = current_user
    @theme = @user.website.theme
    @theme_page = ThemePage.find_by_slug(params[:page_slug])
    @components = Component.joins(:theme_page_components)
                           .where(theme_page_components: { theme_page_id: @theme_page.id })
                           .order('theme_page_components.position')
  end

  def edit_form
    @component = Component.find(params[:component_id])
    @theme_page = ThemePage.find(params[:theme_page_id])
    @theme = @theme_page.theme
    @page_slug = params[:page_slug]
    @editable_fields = JSON.parse(@component.editable_fields)

    # Get existing customizations
    existing_customizations = WebsitesCustomisation.where(
      component_id: @component.id,
      website_id: current_user.website&.id,
      theme_page_id: @theme_page.id
    ).index_by(&:field_name)

    # Build form values - use customization if exists, otherwise use default from editable_fields
    @form_values = {}
    @editable_fields.each do |field_name, default_value|
      if existing_customizations[field_name]
        # User has customized this field, use their custom value
        @form_values[field_name] = existing_customizations[field_name].field_value
      else
        # No customization exists, use the default value from the component template
        @form_values[field_name] = default_value
      end
    end

    Rails.logger.info "Form values for component #{@component.id}: #{@form_values.inspect}"

    render partial: 'manage/website_builder/edit_form', layout: false
  end

  def update_customization
    Rails.logger.info "=== UPDATE_CUSTOMIZATION CALLED ==="
    Rails.logger.info "Request ID: #{request.uuid}"
    Rails.logger.info "Params: #{params.inspect}"

    @component = Component.find(params[:component_id])
    @theme_page = ThemePage.find(params[:theme_page_id])
    @theme = @theme_page.theme
    @page_slug = params[:page_slug]

    customization_params = params[:customization] || {}
    Rails.logger.info "Customization params: #{customization_params.inspect}"

    customization_params.each do |field_name, field_value|
      Rails.logger.info "Processing field: #{field_name} = #{field_value}"

      # Check if any records exist for this combination
      existing_records = WebsitesCustomisation.where(
        website: current_user.website,
        component: @component,
        theme_page_id: @theme_page.id,
        field_name: field_name
      )

      Rails.logger.info "Found #{existing_records.count} existing records for #{field_name}"
      existing_records.each { |r| Rails.logger.info "  - ID: #{r.id}, Value: #{r.field_value}" }

      # First try to find existing record
      customization = existing_records.first

      if customization
        # Update existing record
        customization.update!(field_value: field_value)
        Rails.logger.info "UPDATED existing customization: #{customization.id} for field: #{field_name}"
      else
        # Create new record
        customization = WebsitesCustomisation.create!(
          website: current_user.website,
          component: @component,
          theme_page_id: @theme_page.id,
          field_name: field_name,
          field_value: field_value
        )
        Rails.logger.info "CREATED new customization: #{customization.id} for field: #{field_name}"
      end
    end

    # Check final count
    final_count = WebsitesCustomisation.where(
      website: current_user.website,
      component: @component,
      theme_page_id: @theme_page.id
    ).count
    Rails.logger.info "Final count of customizations for this component: #{final_count}"

    # Reload the components to get fresh data with updated customizations
    @components = Component.joins(:theme_page_components)
                           .where(theme_page_components: { theme_page_id: @theme_page.id })
                           .order('theme_page_components.position')

    # Set instance variables for the partial rendering
    @user = current_user

    # Render the updated partial with the fresh data
    updated_html = render_to_string(
      partial: 'manage/website_builder/components',
      locals: {
        components: @components,
        theme: @theme,
        theme_page: @theme_page
      }
    )

    Rails.logger.info "=== UPDATE_CUSTOMIZATION COMPLETE ==="

    render json: {
      status: 'success',
      message: 'Component updated successfully!',
      updated_html: updated_html
    }
  rescue StandardError => e
    Rails.logger.error "Error in update_customization: #{e.message}"
    Rails.logger.error "Backtrace: #{e.backtrace.join("\n")}"
    render json: { status: 'error', message: e.message }, status: 422
  end

  private

  def current_website_id
    current_user.website.id
  end

end
