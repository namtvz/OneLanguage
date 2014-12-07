class Uploader
  constructor: (channelId, channelUUID, role) ->
    fileUploader = $("#fileupload")

    jqXHR = fileUploader.fileupload
      url: "/attachments"
      formData:
        channel_id: channelId

    fileUploader.bind "fileuploaddone", (e, data) ->
      jsonData = data.jqXHR.responseJSON

      for attachment in jsonData.attachments
        messenger.publish
          channel: channelUUID
          message:
            type: "attachment"
            file_name: attachment.data_file_name
            file_size: attachment.data_file_size
            content_type: attachment.data_content_type
            url: attachment.full_url
            sender_id: attachment.user_id
            message_ref: new Date().getTime()
            sender_role: role

window.Uploader = Uploader