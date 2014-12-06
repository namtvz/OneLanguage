module ApplicationHelper

  def paginate objects, options = {}
    options.reverse_merge!( theme: 'twitter-bootstrap-3' )

    super( objects, options )
  end

  def is_me? id
    current_user.id == id
  end

end
