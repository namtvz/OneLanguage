require 'clockwork'
require './config/boot'
require './config/environment'
module Clockwork
  handler do |job|
    puts "Running #{job}"
  end

  every(10.seconds, 'End inactive channels') {Channel.end_inactive_channels}
end