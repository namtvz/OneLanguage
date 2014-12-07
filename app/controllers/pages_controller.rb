class PagesController < ApplicationController
  skip_before_filter :authenticate_user!
  layout "side_menu"
  def show
    render params[:id]
  end
end