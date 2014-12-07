# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
OneLanguage.onReady ->
  chatContentContainer = $(".chat-content")
  if $('.chat-footer').size()
    chatContentContainer.height($(window).height() - 300)
  else
    chatContentContainer.height($(window).height() - 250)
  $(window).resize ->
    if $('.chat-footer').size()
      chatContentContainer.height($(window).height() - 300)
    else
      chatContentContainer.height($(window).height() - 250)

  initSearchUserAutoComplete = ->
    $('.search-partner, .search-translator').each ->
      if $(this).data().translator
        source = "/search_users?cnid=#{$(this).data().cnid}"
      else
        source = "/search_users"
      $(this).autocomplete
        source: source
        minLength: 0
  initSearchUserAutoComplete()

  $('.create-invite-to-partner').on "click", ->
    if !$('#invite-partner-form').valid()
      return
    cnid = $(this).data().cnid
    email = $('.search-partner').val()
    $.ajax
      method: 'POST'
      url: "/channels/#{cnid}/invite"
      data:
        email: email
        invite_type: 'partner'
      success: (data)->
        if data.success
          $('#parner-invite-modal').modal('hide')
          templete = JST["channels/user_info"]({user: data.user, is_exist: data.is_exist})
          $('.partner-info-area').empty()
          $('.partner-info-area').append(templete)
        else
          $('#partner-error-div').empty()
          $('#partner-error-div').append(data.error)

  $('.create-invite-to-translator').on "click", ->
    if !$('#invite-translator-form').valid()
      return
    cnid = $(this).data().cnid
    email = $('.search-translator').val()
    $.ajax
      method: 'POST'
      url: "/channels/#{cnid}/invite"
      data:
        email: email
        invite_type: 'translator'
      success: (data)->
        if data.success
          $('#translator-invite-modal').modal('hide')
          templete = JST["channels/user_info"]({user: data.user, is_exist: data.is_exist})
          $('.translator-info-area').empty()
          $('.translator-info-area').append(templete)
        else
          $('#translator-error-div').empty()
          $('#translator-error-div').append(data.error)

  $('body').on 'click', '.edit-message', (e) ->
    messageId = $(e.currentTarget).data('id')
    tr = $("tr#" + messageId)
    $("#" + messageId).ScrollTo
      duration: 500
