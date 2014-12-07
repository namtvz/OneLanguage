@timeAgo = (timestamp) ->
  timestamp = parseInt(timestamp)
  if (new Date().getTime()) - timestamp < 86400000
    moment(timestamp).fromNow()
  else
    moment(timestamp).format('lll')

class @ChattingHelper
  constructor: (@role, @chattingTable, @user) ->
    @ownerMessageTemplate = JST["messages/owner"]
    @translatorMessageTemplate = JST["messages/translator"]

  showMessage: (m) ->
    if @role is 'translator'
      @showMessageForTranslator(m)
    else
      @showMessageForPartner(m)
    $('.chat-content').scrollTop(1e10);

  showMessageForTranslator: (m) ->
    if m.sender_id is @user.id
      tr = $('tr#' + m.message_ref)
      tr.find('textarea').val(m.message)
      tr.find('textarea').prop('disabled', true)
      if m.original_role is 'owner'
        tr.find('td.partner-td').append('
          <div class="message-content"><div class="arrow"></div>' + m.message + '</div> <div class="message-time">' + timeAgo(m.message_ref) + '</div>
        ')
      else
        tr.find('td.owner-td').append('
          <div class="message-content"><div class="arrow"></div>' + m.message + '</div> <div class="message-time">' + timeAgo(m.message_ref) + '</div>
        ')
    else
      tr = @translatorMessageTemplate({message: m, isFromOwner: (m.sender_role is 'owner')})
      @chattingTable.append(tr)
    return

  showMessageForPartner: (m) ->
    if $('tr#' + m.message_ref).length > 0
      tr = $('tr#' + m.message_ref)
      if m.sender_role is 'translator' and parseInt(m.original_sender_id) is @user.id
        tr.find('td.partner-td').append('
          <div class="message-content"><div class="arrow"></div>' + m.message + '</div> <div class="message-time">' + timeAgo(m.message_ref) + '</div>
        ')
      else
        tr.find('td.owner-td').append('
          <div class="message-content"><div class="arrow"></div>' + m.message + '</div> <div class="message-time">' + timeAgo(m.message_ref) + '</div>
        ')
    else
      tr = @ownerMessageTemplate({message: m, isOwner: (m.sender_id is @user.id)})
      @chattingTable.append(tr)
    return


