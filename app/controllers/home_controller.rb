class HomeController < ApplicationController
  before_action :authenticate_user!
  def index
  end

  def search_languages
    names = LANGUAGES

    if params[:keyword]
      names = names.select{|n| n.include?(params[:keyword])}
    end

    render json: {languages: names}
  end
end