class ChannelsController < ApplicationController
  before_action :check_role
  before_action :load_user
  def show
  end

  def check_role
    @owner = true
    @translator = true
    @parner = true
  end

  def load_user

    @owner_acc = User.new(name: 'NUS NhanNM', email: 'nhanmn@nustechnology.com', avatar_url: DEFAULT_IMAGE_URL)
    @translator_acc = User.new(name: 'NUS NamTV', email:'namtv@nustechnology.com', avatar_url: DEFAULT_IMAGE_URL)
    @partner_acc = User.new(name: 'NUS ChienTX', email:'chientx@nustechnology.com', avatar_url: DEFAULT_IMAGE_URL)
  end
end
