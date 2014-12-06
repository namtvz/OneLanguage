module ApplicationHelper

  def paginate objects, options = {}
    options.reverse_merge!( theme: 'twitter-bootstrap-3' )

    super( objects, options )
  end

  def my_channel? channel
    channel.owner_id == current_user.id
  end

end
