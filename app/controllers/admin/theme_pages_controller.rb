class Admin::ThemePagesController < ApplicationController
  before_action :set_theme_page, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :authenticate_admin!
  layout 'admin'

  def index
    @theme_pages = ThemePage.includes(:theme).order(:created_at)
  end

  def show
    @theme = Theme.find(params[:id])
    @themePage = @theme.theme_pages.find(params[:theme_page_id])
    @components = Component.all
  end

  def add_component
    @theme = Theme.find(params[:id])
    @themePage = @theme.theme_pages.find(params[:theme_page_id])
    @component = Component.find(params[:component_id])
    @components = Component.all

    # Create the association between theme_page and component
    @theme_page_component = @themePage.theme_page_components.build(
      component: @component,
      position: @themePage.theme_page_components.count + 1
    )

    respond_to do |format|
      if @theme_page_component.save
        @themePage.reload

        format.turbo_stream do
          streams = [
            turbo_stream.replace("component-#{@component.id}",
                                 partial: "component",
                                 locals: { component: @component, added: true }
            )
          ]

          # If this is the first component, remove the empty message and add the component
          if @themePage.theme_page_components.count == 1
            streams << turbo_stream.remove("empty-components-message")
          end

          # Add the new component
          streams << turbo_stream.append("page-components",
                                         partial: "theme_page_component",
                                         locals: { theme_page_component: @theme_page_component }
          )

          # Update the stats with manual pluralization and include the div with classes
          component_text = @components.count == 1 ? "component" : "components"
          added_text = @themePage.theme_page_components.count == 1 ? "component" : "components"

          streams << turbo_stream.replace("component-stats",
                                          '<div id="component-stats" class="text-sm text-gray-500">' +
                                          "#{@components.count} #{component_text} available • #{@themePage.theme_page_components.count} #{added_text} added" +
                                          '</div>'
          )

          render turbo_stream: streams
        end
        format.json { render json: { status: 'success', component: @component } }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash", locals: { error: "Failed to add component" }) }
        format.json { render json: { status: 'error', errors: @theme_page_component.errors } }
      end
    end
  end

  def remove_component
    @theme = Theme.find(params[:id])
    @themePage = @theme.theme_pages.find(params[:theme_page_id])
    @component = Component.find(params[:component_id])
    @components = Component.all

    @theme_page_component = @themePage.theme_page_components.find_by(component: @component)

    respond_to do |format|
      if @theme_page_component
        deleted_position = @theme_page_component.position

        # Delete the component and reorder positions in a transaction
        ActiveRecord::Base.transaction do
          @theme_page_component.destroy!

          # Update positions for all components that came after the deleted one
          @themePage.theme_page_components
                    .where('position > ?', deleted_position)
                    .update_all('position = position - 1')
        end

        @themePage.reload

        # Get all remaining components to update their display
        remaining_components = @themePage.theme_page_components.order(:position).includes(:component)

        format.turbo_stream do
          streams = [
            # Remove the deleted component
            turbo_stream.remove("theme-page-component-#{@theme_page_component.id}"),
            # Update the available component to show "Add" again
            turbo_stream.replace("component-#{@component.id}",
                                 partial: "component",
                                 locals: { component: @component, added: false }
            )
          ]

          # Update each remaining component to show correct position
          remaining_components.each do |tpc|
            streams << turbo_stream.replace("theme-page-component-#{tpc.id}",
                                            partial: "theme_page_component",
                                            locals: { theme_page_component: tpc })
          end

          # If no components left, show the empty message
          if remaining_components.empty?
            streams << turbo_stream.append("page-components",
                                           '<div id="empty-components-message" class="text-center py-8">
                                           <div class="w-12 h-12 mx-auto mb-4 text-gray-400">
                                             <svg fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                               <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"></path>
                                             </svg>
                                           </div>
                                           <p class="text-gray-500 text-sm">No components added yet.</p>
                                           <p class="text-gray-400 text-xs mt-1">Add components from the left panel to get started</p>
                                         </div>')
          end

          # Update the stats with manual pluralization and include the div with classes
          component_text = @components.count == 1 ? "component" : "components"
          added_text = @themePage.theme_page_components.count == 1 ? "component" : "components"

          streams << turbo_stream.replace("component-stats",
                                          '<div id="component-stats" class="text-sm text-gray-500">' +
                                          "#{@components.count} #{component_text} available • #{@themePage.theme_page_components.count} #{added_text} added" +
                                          '</div>'
          )

          render turbo_stream: streams
        end
        format.json { render json: { status: 'success' } }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash", locals: { error: "Component not found" }) }
        format.json { render json: { status: 'error', errors: "Component not found" } }
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash", locals: { error: "Failed to remove component: #{e.message}" }) }
      format.json { render json: { status: 'error', errors: e.message } }
    end
  end

  def new
    @theme_page = ThemePage.new
  end

  def create
    @theme_page = ThemePage.new(theme_page_params)

    if @theme_page.save
      redirect_to admin_themes_show_path(id: @theme_page.theme_id), notice: 'Theme page was successfully created.'
    else
      render :new
    end
  end

  def edit
    @theme = Theme.find(params[:id])
  end

  def update
    if @theme_page.update(theme_page_params)
      redirect_to admin_themes_show_path(id: @theme_page.theme_id), notice: 'Theme page was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @theme_page.destroy
    redirect_to admin_theme_pages_path, notice: 'Theme page was successfully deleted.'
  end

  private

  def set_theme_page
    @theme_page = ThemePage.find(params[:id])
  end

  def theme_page_params
    params.require(:theme_page).permit(:theme_id, :page_type, :component_order, :package)
  end

  def reorder_positions(theme_page, deleted_position)
    # Update positions for all components that came after the deleted one
    theme_page.theme_page_components
              .where('position > ?', deleted_position)
              .update_all('position = position - 1')
  end
end