class AttachmentsController < ApplicationController
  before_filter :authenticate_user!

  def create
    attachments = []
    params[:files].each do |file|
      attachment = Attachment.new
      attachment.data = file

      attachment.user = current_user
      attachment.channel_id = params[:channel_id]

      attachment.save

      attachments << attachment
    end

    render json: {attachments: attachments.as_json(methods: :full_url)}
  end
end