class ChannelsController < ApplicationController
  before_action :find_channel, only: [:show]
  before_action :check_role
  before_action :load_user

  def index
    @channels = current_user.get_my_channels.includes(:owner, :translator, :partner)
    @term = params[:term].strip if params[:term]
    @channels = @channels.search(current_user, @term) if !@term.blank?
    @channels = @channels.order('channels.started_at DESC, channels.created_at DESC').page(params[:page] || 1)

    render :index, layout: "side_menu"
  end

  def show
    @owner_acc = @channel.owner
  end

  def check_role
    @owner = true
    @translator = false
    @partner = false
  end

  def load_user
    #@owner_acc = User.new(name: 'NUS NhanNM', email: 'nhanmn@nustechnology.com', avatar_url: DEFAULT_IMAGE_URL)
    @translator_acc = User.new(name: 'NUS NamTV', email:'namtv@nustechnology.com', avatar_url: DEFAULT_IMAGE_URL)
    @partner_acc = User.new(name: 'NUS ChienTX', email:'chientx@nustechnology.com', avatar_url: DEFAULT_IMAGE_URL)
  end

  private
  def find_channel
    @channel = Channel.find(params[:id])
  end
end
