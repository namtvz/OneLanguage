class HomeController < ApplicationController
  before_action :authenticate_user!
  def index
  end

  def search_languages
    names = LANGUAGES

    if params[:keyword]
      names = names.select{|n| n.downcase.include?(params[:keyword].downcase)}
    end

    render json: {languages: names}
  end

  def search_users
    users = User.where.not(id: current_user.id)
    if params[:cnid]
      channel = Channel.find params[:cnid]
      lg1_userids = Language.where(name: channel.owner_language).pluck(:user_id)
      lg2_userids = Language.where(name: channel.partner_language).pluck(:user_id)
      user_ids = lg1_userids - (lg1_userids - lg2_userids)
      users = users.where(id: user_ids)
    end
    if params[:term].present?
      users = users.where("name like :term OR email like :term", {term: "%#{params[:term]}%"})
    end
    users = users.collect{|user| {label: "#{user.name} (#{user.email})", value: user.email}}
    render json: users
  end
end