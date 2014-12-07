if ENV['NEED_UPDATE_ONLINE'].present?
  Channel.update_online_on_start
  Channel.update_online_status
end
