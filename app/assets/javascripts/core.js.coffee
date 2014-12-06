class Application
  constructor: (@window) ->
    @root = $('html')

  # Setup callback that gets called when page is ready
  onReady: (callback) -> $(callback)

  # Setup event handler on given selector
  on: (selector, evtName, handler) ->
    @onReady => @root.on(evtName, selector, handler)

window.OneLanguage = new Application(this)

