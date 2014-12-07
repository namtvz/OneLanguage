class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def self.provides_callback_for(provider)
    class_eval %Q{
      def #{provider}
        @user = User.find_for_oauth(env["omniauth.auth"], current_user)
        if session[:is_translator].present?
          @user.update_attributes(is_translator: true)
          session.delete(:is_translator)
        else
          @user.update_attributes(is_guest: true)
          session.delete(:is_guest)
        end
        if @user.persisted?
          return_url = session.delete :return_url
          if return_url.present?
            sign_in @user
            redirect_to return_url and return
          else
            sign_in_and_redirect @user, event: :authentication and return
          end
          set_flash_message(:notice, :success, kind: #{provider}.capitalize) if is_navigational_format?
        else
          session["devise.#{provider}_data"] = env["omniauth.auth"]
          redirect_to new_user_registration_url
        end
      end
    }
  end

  [:facebook, :google_oauth2].each do |provider|
    provides_callback_for provider
  end
end
