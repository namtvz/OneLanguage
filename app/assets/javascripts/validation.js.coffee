root = exports ? this
$(document).ready ->
  jQuery.validator.addMethod "notEqual", ((value, element, param) ->
    @optional(element) or value isnt $(param).val()
  ), "This has to be different..."


@validateDeviseForm = ->
  $('.devise-form').validate
    rules:
      'user[email]':
        required: true
        email: true
      'user[password]':
        required: true
        minlength: 8
      'user[password_confirmation]':
        equalTo: '#user_password'
      'user[current_password]':
        required: true
    messages:
      'user[password_confirmation]':
        equalTo: 'Please enter the same with password.'

@validateNewChannel = ->
  $('#new-channel-form').validate
    rules:
      "channel[name]":
        required: true
      "channel[owner_language]":
        required: true
        notEqual: '#partner_language'
      "channel[partner_language]":
        required: true
    messages:
      "channel[name]":
        required: "Please enter channel name"
      "channel[owner_language]":
        required: "Please select owner's language"
        notEqual: "Owner language must be different from partner's language"
      "channel[partner_language]":
        required: "Please select partner's language"
@validateInviteForm = ->
  $('#invite-partner-form').validate
    rules:
      "search-partner":
        required: true
        email: true
    messages:
      "search-partner":
        required: "Please enter name or email for searching..."
  $('#invite-translator-form').validate
    rules:
      "search-translator":
        required: true
        email: true
    messages:
      "search-translator":
        required: "Please enter name or email for searching..."