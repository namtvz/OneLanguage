class @Messenger
  constructor: (@publishKey, @subscribeKey) ->

  connect: (uuid) ->
    console.log "Init User"
    @uuid = uuid
    @connection = PUBNUB.init(
      publish_key: @publishKey
      subscribe_key: @subscribeKey
      uuid: @uuid
    )
    return

  subscribe: (options) ->
    console.log "User subscribe channel"
    @connection.subscribe.apply @connection, arguments
    return

  unsubscribe: (options) ->
    @connection.unsubscribe.apply @connection, arguments
    return

  publish: ->
    @connection.publish.apply @connection, arguments
    return

  history: ->
    @connection.history.apply @connection, arguments
    return
