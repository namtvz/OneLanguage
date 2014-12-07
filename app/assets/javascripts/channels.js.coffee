# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
OneLanguage.onReady ->
  chatContentContainer = $(".chat-content")

  chatContentContainer.height($(window).height() - 300)
  $(window).resize ->
    chatContentContainer.height($(window).height() - 300)

  initSearchUserAutoComplete = ->
    $('.search-people').each ->
      if $(this).data().translator
        source = "/search_users?cnid=#{$(this).data().cnid}"
      else
        source = "/search_users"
      $(this).autocomplete
        source: source
        minLength: 0
  initSearchUserAutoComplete()