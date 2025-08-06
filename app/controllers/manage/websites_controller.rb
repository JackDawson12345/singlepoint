# app/controllers/manage/websites_controller.rb
class Manage::WebsitesController < ApplicationController
  before_action :set_website, only: [:update]
  before_action :authenticate_user!
  before_action :account_setup?
  layout 'manage', except: [:preview]

  # GET /websites/new
  def new
    if current_user.website
      redirect_to manage_website_path
    end

    @website = Website.new
    @users = User.all
    @themes = Theme.all
  end


  # POST /websites
  def create
    @website = Website.new(website_params)

    if @website.save
      redirect_to manage_website_path, notice: 'Website was successfully created.'
    else
      @users = User.all
      @themes = Theme.all
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /websites/1
  def update
    if @website.update(website_params)
      redirect_to manage_website_path, notice: 'Website was successfully updated.'
    else
      @users = User.all
      @themes = Theme.all
      render :edit, status: :unprocessable_entity
    end
  end

  def preview
    @user = current_user
    @theme = @user.website.theme
    @theme_page = ThemePage.find_by_slug(params[:page_slug])
    @components = Component.joins(:theme_page_components)
                           .where(theme_page_components: { theme_page_id: @theme_page.id })
                           .order('theme_page_components.position')
  end

  def settings
    @user = current_user
    @website = @user.website
    @domain_name = @user.account_setup.domain_name
  end

  def settings_save
    @user = current_user
    @website = @user.website
    @website.name = params[:name]
    @website.save
    redirect_to manage_website_settings_path, notice: 'Website Settings was successfully updated.'

  end

  private

  def set_website
    @website = Website.find(params[:id])
  end

  def website_params
    params.require(:website).permit(:user_id, :theme_id, :name, :published)
  end
end