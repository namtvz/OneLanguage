class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_filter :authenticate_user!

  def configure_permitted_parameters
    if params[:action] == "create"
      devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:name, :email, :password, :password_confirmation) }
    elsif params[:action] == "update"
      devise_parameter_sanitizer.for(:account_update) {
        |u| u.permit(:name, :email, :password, :password_confirmation, :current_password)
      }
    end
  end

  def after_sign_in_path_for(resource)
    return_url = session[:return_url]
    if return_url
      session[:return_url] = nil
      return_url
    else
      super(resource)
    end
  end
end
