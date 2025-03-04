class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  def after_sign_out_path_for(resource_or_scope)
    new_user_registration_path # Redirect to the sign-up page
  end

  def after_sign_in_path_for(resource)
    if resource.admin?
      admin_dashboard_path # Redirect to the admin dashboard
    elsif resource.charity?
      charity_dashboard_path # Redirect to the charity dashboard
    else
      root_path # Default redirect path (if needed)
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :company_name, :ein_number, :tax_number])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :company_name,:ein_number, :tax_number])
  end
end
