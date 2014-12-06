class ChannelsController < ApplicationController
  before_action :check_role
  def show
  end

  def check_role
    @owner = false
    @translator = true
    @parner = false
  end

end
