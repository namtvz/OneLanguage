class ChannelMailer < ActionMailer::Base
  default from: "<1Language> OneLanguage@nustechnology.com"
  def send_invitation channel, email, type
    @channel = channel
    @email = email
    @owner = channel.owner
    @type = type
    @access_code = if @type == "partner"
      channel.partner_access_code
    else
      channel.translator_access_code
    end
    mail(to: email, subject: "[#{@owner.name}] You have been invited to #{@channel.name}")
  end
end