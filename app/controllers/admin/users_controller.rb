class Admin::UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :reset_password, :update_password]
  before_action :authenticate_user!
  before_action :authenticate_admin!
  layout 'admin'

  # GET /admin/users
  def index
    @users = User.all.order(:last_name, :first_name)
  end

  # GET /admin/users/1
  def show
  end

  # GET /admin/users/new
  def new
    @user = User.new
  end

  # GET /admin/users/1/edit
  def edit
  end

  # GET /admin/users/1/reset_password
  def reset_password
  end

  # POST /admin/users
  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to admin_users_show_path(@user), notice: 'User was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /admin/users/1
  def update
    if @user.update(user_params_without_password)
      redirect_to admin_users_show_path(@user), notice: 'User was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # PATCH /admin/users/1/reset_password
  def update_password
    if @user.update(password_params)
      redirect_to admin_users_show_path(@user), notice: 'Password was successfully updated.'
    else
      render :reset_password, status: :unprocessable_entity
    end
  end

  # DELETE /admin/users/1
  def destroy
    @user.destroy
    redirect_to admin_users_path, notice: 'User was successfully deleted.'
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :role, :first_name, :last_name)
  end

  def user_params_without_password
    params.require(:user).permit(:email, :role, :first_name, :last_name)
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end