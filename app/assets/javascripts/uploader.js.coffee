class Uploader
  constructor: (channelId, channelUUID) ->
    fileUploader = $("#fileupload")

    jqXHR = fileUploader.fileupload
      url: "/attachments"
      formData:
        channel_id: channelId

    fileUploader.bind "fileuploaddone", (e, data) ->
      jsonData = data.jqXHR.responseJSON

      console.log jsonData.attachments

      for attachment in jsonData.attachments
        console.log attachment
        messenger.publish
          channel: channelUUID
          message:
            type: "attachment"
            file_name: attachment.data_file_name
            file_size: attachment.data_file_size
            url: attachment.data_url
            sender_id: attachment.user_id
            message_ref: new Date().getTime()

window.Uploader = Uploader