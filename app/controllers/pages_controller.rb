class PagesController < ApplicationController
  skip_before_filter :authenticate_user!
  layout "side_menu"
  APPLICATION_LAYOUTS = ["payment"]
  def show
    if APPLICATION_LAYOUTS.include? params[:id]
      render params[:id], layout: "application"
    else
      render params[:id]
    end
  end
end