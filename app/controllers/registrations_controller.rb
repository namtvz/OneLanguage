class RegistrationsController < Devise::RegistrationsController
  def create
    build_resource(sign_up_params)

    if resource.save
      if session[:is_translator].present?
        resource.update_attributes(is_translator: true)
        session.delete(:is_translator)
      else
        resource.update_attributes(is_guest: true)
        session.delete(:is_guest)
      end
      if resource.active_for_authentication?
        location_path = session[:return_url].present? ? session[:return_url] : after_sign_up_path_for(resource)
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_up(resource_name, resource)
        respond_with resource, :location => location_path
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  def upload_avatar
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)

    self.resource.avatar = params[:avatar]

    self.resource.save

    render json: self.resource
  end

  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    is_changing_password = !params[:user][:current_password].blank?

    successfully_updated = if is_changing_password
      resource.update_with_password(account_update_params)
    else
      params[:user].delete(:current_password)
      languages = params[:language_names].split(",")

      unless languages.empty?
        resource.languages.where.not(name: languages).destroy_all
        languages.each do |l|
          resource.languages.build(name: l) if !resource.languages.exists?(name: l)
        end
      end

      resource.update_without_password(account_update_params)
    end

    if successfully_updated
      if is_navigational_format?
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
          :update_needs_confirmation : :updated
        set_flash_message :notice, flash_key
      end
      sign_in resource_name, resource, bypass: true
      redirect_to edit_user_registration_path
    else
      clean_up_passwords resource
      respond_with resource
    end
  end
end
