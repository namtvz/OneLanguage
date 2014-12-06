OneLanguage.onReady ->
  fileUpload = $("#upload-new-avatar input[type=file]")

  fileUpload.fileupload
    url: "/users/upload_avatar"

  fileUpload.bind "fileuploaddone", (e, data) ->
    jsonData = data.jqXHR.responseJSON

    window.location.reload()

  fileUpload.bind "fileuploadprogress", (e, data) ->
    $("#uploading-text").text("Uploading...")