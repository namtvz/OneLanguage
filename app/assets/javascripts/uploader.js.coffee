class Uploader
  constructor: (channel, userId, successCallback) ->
    fileUploader = $("#fileupload")

    jqXHR = fileUploader.fileupload
      url: "/attachments"

    fileUploader.bind "fileuploaddone", ->
      $(successCallback)

OneLanguage.onReady ->
  new Uploader("testChannel", 5)