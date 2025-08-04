class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def authenticate_admin!
    unless current_user.role == 0
      redirect_to root_path
    end
  end

  protected

  # This works for both sign in AND sign up
  def after_sign_in_path_for(resource)
    redirect_based_on_role(resource)
  end

  def after_sign_up_path_for(resource)
    redirect_based_on_role(resource)
  end

  private

  def redirect_based_on_role(resource)
    case resource.role
    when 0
      admin_dashboard_path
    when 1
      manage_dashboard_path
    else
      root_path
    end
  end
end
