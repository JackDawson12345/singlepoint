class Manage::ServicesController < ApplicationController
  before_action :set_website_service, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  layout "manage"

  # GET /manage/services
  def index
    @website_services = WebsiteService.where(user_id: current_user.id)
  end

  # GET /manage/services/1
  def show
  end

  # GET /manage/services/new
  def new
    @website_service = WebsiteService.new
  end

  # GET /manage/services/1/edit
  def edit

  end

  # POST /manage/services
  def create
    @website_service = WebsiteService.new(website_service_params)

    if @website_service.save
      redirect_to manage_services_show_path(@website_service), notice: 'Website service was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /manage/services/1
  def update
    if @website_service.update(website_service_params)
      redirect_to manage_services_show_path(@website_service), notice: 'Website service was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /services/1
  def destroy
    @website_service.destroy
    redirect_to manage_services_path, notice: 'Website service was successfully deleted.'
  end

  private

  def set_website_service
    @website_service = WebsiteService.find(params[:id])
  end

  def website_service_params
    params.require(:website_service).permit(:website_id, :title, :text, :user_id, :icon, features: {})
  end
end