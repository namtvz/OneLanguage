class AttachmentsController < ApplicationController
  before_filter :authenticate_user!

  def create
    attachments = []
    params[:files].each do |file|
      attachment = Attachment.new
      attachment.file = file

      attachment.save

      attachments << attachment
    end

    render json: {attachments: attachments}
  end
end