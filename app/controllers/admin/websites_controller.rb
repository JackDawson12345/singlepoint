# app/controllers/admin/websites_controller.rb
class Admin::WebsitesController < ApplicationController
  before_action :set_website, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :authenticate_admin!
  layout 'admin'

  def index
    @websites = Website.includes(:user, :theme).order(created_at: :desc)
  end

  def show
  end

  def new
    @website = Website.new
  end

  def create
    @website = Website.new(website_params)

    if @website.save
      redirect_to admin_websites_show_path(@website), notice: 'Website was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @website.update(website_params)
      redirect_to admin_websites_show_path(@website), notice: 'Website was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @website.destroy
    redirect_to admin_websites_path, notice: 'Website was successfully deleted.'
  end

  private

  def set_website
    @website = Website.find(params[:id])
  end

  def website_params
    params.require(:website).permit(:name, :published, :user_id, :theme_id)
  end
end