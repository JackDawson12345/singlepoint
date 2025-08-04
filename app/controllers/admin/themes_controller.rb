# app/controllers/admin/themes_controller.rb
class Admin::ThemesController < ApplicationController
  before_action :set_theme, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :authenticate_admin!
  layout "admin"

  def index
    @themes = Theme.all.order(:name)
  end

  def show
    @themePages = Theme.find(params[:id]).theme_pages
  end

  def new
    @theme = Theme.new
  end

  def create
    @theme = Theme.new(theme_params)

    if @theme.save
      redirect_to admin_themes_show_path(@theme), notice: 'Theme was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @theme.update(theme_params)
      redirect_to admin_themes_show_path(@theme), notice: 'Theme was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @theme.destroy
    redirect_to admin_themes_path, notice: 'Theme was successfully deleted.'
  end

  private

  def set_theme
    @theme = Theme.find(params[:id])
  end

  def theme_params
    params.require(:theme).permit(:name, :description, :image_url)
  end
end