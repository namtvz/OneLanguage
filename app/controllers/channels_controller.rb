class ChannelsController < ApplicationController
  before_action :find_channel, only: [:show, :invite]
  before_action :check_role, only: [:show]
  before_action :load_user, only: [:show]

  def index
    @channels = current_user.get_my_channels.includes(:owner, :translator, :partner)
    @term = params[:term].strip if params[:term]
    @channels = @channels.search(current_user, @term) if !@term.blank?
    @channels = @channels.order('channels.started_at DESC, channels.created_at DESC').page(params[:page] || 1)

    render :index, layout: "side_menu"
  end

  def create
    channel = Channel.new channel_params
    if channel.save
      redirect_to channel_path(channel)
    else
      redirect_to channels_path
    end
  end

  def show
    @owner_acc = @channel.owner
    @role = @channel.who_is? current_user

    if (@role == 'partner' && @channel.partner_online) || (@role == 'translator' && @channel.translator_online) || (@role == 'owner' && @channel.owner_online)
      flash[:error] = 'You or someone is already using this channel. Did you use this link in 2 tabs?'
      redirect_to root_path and return
    end

    case @role
    when 'owner'
      @owner = true
      @uuid = @channel.owner_uuid
    when 'translator'
      @translator = true
      @uuid = @channel.translator_uuid
    when 'partner'
      @partner = true
      @uuid = @channel.partner_uuid
    end
  end

  def check_role
    @owner = false
    @translator = false
    @partner = false
  end

  def load_user
    @translator_acc = @channel.translator
    @partner_acc = @channel.partner
  end

  def invite
    user = User.find_by_email params[:email]
    is_exist = false
    if user
      is_exist = true
      if params[:invite_type] == "partner"
        @channel.update_attributes(partner_id: user.id)
      elsif params[:invite_type] == "translator"
        @channel.update_attributes(translator_id: user.id)
      end
    else
      if params[:invite_type] == "partner"
        @channel.update_attributes(partner_id: -1)
      elsif params[:invite_type] == "translator"
        @channel.update_attributes(translator_id: -1)
      end
    end

    if params[:invite_type] == "partner"
      ChannelMailer.delay.send_invitation(@channel, params[:email], 'partner')
    elsif params[:invite_type] == "translator"
      ChannelMailer.delay.send_invitation(@channel, params[:email], 'translator')
    end
    if user
      user_info = {
        name: user.name,
        avatar_type: "#{params[:invite_type]}-avatar",
        channel_user_id: user.id,
        avatar_url: user.avatar.url(:small),
        channel_language: params[:invite_type] == "partner" ? @channel.partner_language : ""
      }
    else
      user_info = {
        name: "Guest",
        avatar_type: "#{params[:invite_type]}-avatar",
        channel_user_id: 0,
        avatar_url: "/assets/#{DEFAULT_IMAGE_URL}",
        channel_language: params[:invite_type] == "partner" ? @channel.partner_language : ""
      }
    end
    render json: {success: true, user: user_info, is_exist: is_exist}
  end

private
  def find_channel
    @channel = Channel.friendly.find(params[:id])
  end
  def channel_params
    channel_params = params[:channel].permit(:name, :owner_language, :partner_language)
    channel_params[:owner_id] = current_user.id
    channel_params
  end
end