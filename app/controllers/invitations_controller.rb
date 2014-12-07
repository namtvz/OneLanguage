class InvitationsController < ApplicationController
  skip_before_filter :authenticate_user!

  def show
    access_code = params[:id]
    if !access_code.blank?
      channel_data = Channel.data_for_token access_code.strip

      if channel_data.blank?
        respond_invalid_token
      else
        @channel = channel_data[:channel]
        @role = channel_data[:role]
        if (@role == 'partner' && @channel.partner_online) || (@role == 'translator' && @channel.translator_online)
          respond_already_joined
        else
          if user_signed_in?
            if ![@channel.owner_id, @channel.partner_id, @channel.translator_id].include? current_user.id
              if @role == 'partner'
                @channel.partner_id = current_user.id
              else # Translator
                @channel.translator_id = current_user.id
              end
              @channel.save
            end

            redirect_to @channel
          else # Not logged user
            session[:return_url] = invitation_path(access_code)
            if @role == 'partner'
              render
            else
              flash[:invitation_info] = "#{@channel.owner.name} invited you into a channel as Translator. Signin or create an account to join it."

              redirect_to new_user_session_path
            end
          end
        end
      end
    end
  end

  def create
    if !params[:name].blank?
      user = User.create(name: params[:name], email: "user#{Time.now.to_f}@example.com", password: Devise.friendly_token, is_guest: true)
      sign_in user
      return_url = session[:return_url]
      session[:return_url] = nil
      redirect_to return_url
    else
      render :show
    end
  end

  private
  def respond_invalid_token
    flash[:error] = 'Invalid token. Did you use wrong link?'
    redirect_to root_path
  end

  def respond_already_joined
    flash[:error] = 'You or someone is already using this channel. Did you use this link in 2 tabs?'
    redirect_to root_path
  end

  def valid_role?(channel_data)

  end

  def method_name

  end
end