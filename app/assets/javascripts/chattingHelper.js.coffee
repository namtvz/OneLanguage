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

    @attachmentMessageTemplate = JST["messages/attachment"]

    @contentTemplate = JST["messages/content"]
  showMessage: (m) ->
    if @role is 'translator'
      @showMessageForTranslator(m)
    else
      @showMessageForPartner(m)
      $('.chat-content').scrollTop(1e10);

    $('.chat-content textarea').autosize
      append: false

  updateOrAppendNewMessage: (message, messageContainer) ->
    content = @contentTemplate({m: message})

    if messageContainer.children().length > 0
      #Remove older text
      messageContainer.find(".old-text").remove()

      #Mark the current text as old text
      oldMessageDiv = messageContainer.find(".plain-text")
      newMessageDiv = oldMessageDiv.clone()

      oldMessageDiv.removeClass("new-text").addClass("old-text")

      #Append the new text
      newMessageDiv.removeClass("old-text").addClass("new-text").html(message.message)

      messageContainer.find(".message-content").append(newMessageDiv)
    else
      messageContainer.append(content)

  showMessageForTranslator: (m) ->
    if m.sender_id is @user.id
      tr = $('tr#' + m.message_ref)
      tr.find('textarea').val(m.message)
      tr.find('textarea').trigger('autosize.resize')

      messageContainer = if m.original_role is 'owner'
        tr.find('td.partner-td')
      else
        tr.find('td.owner-td')

      @updateOrAppendNewMessage(m, messageContainer)

    else
      tr = @translatorMessageTemplate({message: m, isFromOwner: (m.sender_role is 'owner')})
      @chattingTable.append(tr)
    return

  showMessageForPartner: (m) ->
    if $('tr#' + m.message_ref).length > 0
      tr = $('tr#' + m.message_ref)

      messageContainer = if m.sender_role is 'translator' and m.original_sender_id == @user.id
        console.log "KAKA"
        tr.find('td.partner-td')
      else
        tr.find('td.owner-td')

      @updateOrAppendNewMessage(m, messageContainer)
    else
      tr = @ownerMessageTemplate({message: m, isOwner: (m.sender_id is @user.id)})
      @chattingTable.append(tr)
    return
  showAttachmentMessage: (message) ->
    tr = @attachmentMessageTemplate({message: message, isFromOwner: (message.sender_role is 'owner')})
    @chattingTable.append(tr)

    $('.chat-content').scrollTop(1e10);

