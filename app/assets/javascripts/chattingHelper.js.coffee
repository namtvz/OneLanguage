@timeAgo = (timestamp) ->
  timestamp = parseInt(timestamp)
  if (new Date().getTime()) - timestamp > 86400
    moment(timestamp).fromNow()
  else
    moment(timestamp).format('lll')

class @ChattingHelper
  constructor: (@role, @chattingTable, @user) ->

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
      tr = $('<tr></tr>')
      tr.attr('id', m.message_ref)
      if m.sender_role is 'owner'
        tr.addClass 'from-owner'
        tr.append('<td class="owner-td"><div class="message-content"><div class="arrow"></div>' + m.message + '</div> <div class="message-time">' + timeAgo(m.message_ref) + '</div></td><td class="translator-td"><div class="message-content"><div class="arrow"></div><textarea class="translate-input" o_role="' + m.sender_role + '"u_id="' + m.sender_id + '" m_ref="' + m.message_ref + '"placeholder="Enter translated text ..."></textarea></div></td><td class="partner-td"></td>
        ')
      else
        tr.addClass 'from-partner'
        tr.append('<td class="owner-td"></td><td class="translator-td"><div class="message-content"><div class="arrow"></div><textarea class="translate-input" o_role="' + m.sender_role + '"u_id="' + m.sender_id + '"m_ref="' + m.message_ref + '"placeholder="Enter translated text ..."></textarea></div></td><td class="partner-td"><div class="message-content"><div class="arrow"></div>' + m.message + '</div> <div class="message-time">' + timeAgo(m.message_ref) + '</div></td>
        ')
      @chattingTable.append(tr)
    return

  showMessageForPartner: (m) ->
    if $('tr#' + m.message_ref).length > 0
      tr = $('tr#' + m.message_ref)
      if (m.sender_id is @user.id)
        tr.find('td.owner-td').append('
          <div class="message-content"><div class="arrow"></div>' + m.message + '</div> <div class="message-time">' + timeAgo(m.message_ref) + '</div>
        ')
      else
        if m.sender_role is 'translator' and parseInt(m.original_sender_id) is @user.id
          tr.find('td.partner-td').append('
            <div class="message-content"><div class="arrow"></div>' + m.message + '</div> <div class="message-time">' + timeAgo(m.message_ref) + '</div>
          ')
        else
          tr.find('td.owner-td').append('
            <div class="message-content"><div class="arrow"></div>' + m.message + '</div> <div class="message-time">' + timeAgo(m.message_ref) + '</div>
          ')
    else
      tr = $('<tr></tr>')
      tr.attr('id', m.message_ref)
      if m.sender_id is @user.id
        tr.addClass 'from-owner'
        tr.append('<td class="owner-td"><div class="message-content"><div class="arrow"></div>' + m.message + '</div> <div class="message-time">' + timeAgo(m.message_ref) + '</div></td><td class="translator-td"></td><td class="partner-td"></td>
        ')
      else
        tr.addClass 'from-partner'
        tr.append('<td class="owner-td"></td><td class="translator-td"></td><td class="partner-td"><div class="message-content"><div class="arrow"></div>' + m.message + '</div> <div class="message-time">' + timeAgo(m.message_ref) + '</div></td>
        ')
      @chattingTable.append(tr)

    return

