class PubnubService
  def self.instance
    @@pubnub ||= Pubnub.new(
      :subscribe_key    => 'sub-c-ccf40038-78ac-11e4-a5ea-02ee2ddab7fe',
      :publish_key      => 'pub-c-547232aa-3488-4d2d-8cbb-2fd4072a0697',
      :origin           => 'pubsub.pubnub.com',
      :error_callback   => lambda { |msg|
        puts "Error callback says: #{msg.inspect}"
      },
      :connect_callback => lambda { |msg|
        puts "CONNECTED: #{msg.inspect}"
      }
    )
  end
end