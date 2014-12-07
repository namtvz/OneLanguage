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

    @typingMessageTemplate = JST["messages/typing"]

    @editNotificationTemplate = JST["messages/edit"]

  showMessage: (m) ->
    @chattingTable.find('tr.typing-text').remove()
    if @role is 'translator'
      @showMessageForTranslator(m)
    else
      @showMessageForPartner(m)
      $('.chat-content').scrollTop(1e10);

    $('.chat-content textarea').autosize
      append: false

  updateOrAppendNewMessage: (message, messageContainer) ->
    content = @contentTemplate({m: message})

    if messageContainer.children().length > 0 && messageContainer.children(".typing-text").length == 0
      #Remove older text
      messageContainer.find(".old-text").remove()
      messageContainer.find(".transition-arrow").remove()

      #Mark the current text as old text
      oldMessageDiv = messageContainer.find(".plain-text")
      newMessageDiv = oldMessageDiv.clone()

      oldMessageDiv.removeClass("new-text").addClass("old-text")

      #Append the new text
      newMessageDiv.removeClass("old-text").addClass("new-text").html(message.message)
      messageContainer.find(".message-content").append(newMessageDiv)
      messageContainer.find('.message-content .new-text').before("<span class='transition-arrow'> -> </span>")
    else
      messageContainer.html(content)

  showMessageForTranslator: (m) ->
    if m.sender_id is @user.id
      tr = $('tr#' + m.message_ref)
      tr.find('textarea').val(m.message)
      if m.message && m.message.length > 0
        tr.find('textarea').addClass('has-message')
        tr.find('textarea').attr("old-message", m.message)

      tr.find('textarea').trigger('autosize.resize')

      messageContainer = if m.original_role is 'owner'
        tr.find('td.partner-td')
      else
        tr.find('td.owner-td')

      @updateOrAppendNewMessage(m, messageContainer)

    else
      tr = @translatorMessageTemplate({message: m, isFromOwner: (m.sender_role is 'owner')})
      @chattingTable.append(tr)
      $(".chat-content").scrollTop(1e10)
    return

  showMessageForPartner: (m) ->
    if $('tr#' + m.message_ref).length > 0
      tr = $('tr#' + m.message_ref)
      messageContainer = if m.sender_role is 'translator' and m.original_sender_id == @user.id
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

  showTranslatingMessage: (m) ->
    if @role isnt 'translator'
      tr = $('tr#' + m.message_ref)
      if m.original_uid is @user.id
        if m.start
          tr.find('td.partner-td').append('
            <div class="typing-text">Translating...</div>
          ')
        else
          @chattingTable.find('div.typing-text').remove()
      else
        if m.start
          tr.find('td.owner-td').append('
            <div class="typing-text text-right">Translating...</div>
          ')
        else
          @chattingTable.find('div.typing-text').remove()

  showTypingMessage: (m) ->
    if @role is 'translator'
      if m.start
        if @chattingTable.find('tr.typing-text').length > 0
          tr = @chattingTable.find('tr.typing-text')
          if m.sender_role is 'owner'
            tr.find('td.owner-td').html('Typing...')
          else
            tr.find('td.partner-td').html('Typing...')
        else
          tr = @typingMessageTemplate({message: m, isOwner: (m.sender_role is 'owner')})
          @chattingTable.append(tr)
      else
        if m.sender_role is 'owner'
          @chattingTable.find('tr.typing-text').find('td.owner-td').html('')
        else
          @chattingTable.find('tr.typing-text').find('td.partner-td').html('')

    else
      if m.sender_id isnt @user.id
        if m.start
          tr = $('
            <tr class="typing-text"><td class="owner-td"></td><td></td><td class="partner-td text-right">Typing...</td></tr>
          ')
          @chattingTable.append(tr)
        else
          @chattingTable.find('tr.typing-text').remove()

  showEditMessage: (m) ->
    tr = $("tr#" + m.message_ref)
    tr.find('textarea').val(m.message)
    tr.find('textarea').attr("old-message", m.message)

    messageFromLeftSide = ((m.original_role is 'owner' && @role == 'translator') || m.original_sender_id == @user.id)

    messageContainer = if messageFromLeftSide
      tr.find('td.partner-td')
    else
      tr.find('td.owner-td')

    @updateOrAppendNewMessage(m, messageContainer)

    tr = @editNotificationTemplate({message: m, isOnLeftSide: !messageFromLeftSide})

    @chattingTable.append(tr)


