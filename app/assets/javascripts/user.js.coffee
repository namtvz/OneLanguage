OneLanguage.onReady ->
  fileUpload = $("#upload-new-avatar input[type=file]")

  fileUpload.fileupload
    url: "/users/upload_avatar"

  fileUpload.bind "fileuploaddone", (e, data) ->
    jsonData = data.jqXHR.responseJSON

    window.location.reload()

  fileUpload.bind "fileuploadprogress", (e, data) ->
    $("#uploading-text").text("Uploading...")


  #Initialize tokenizer
  inputTokenizer = $("#user_language_names")

  if inputTokenizer.length == 0
    return

  currentLanguages = inputTokenizer.val().split(",")

  inputTokenizer.val("")

  inputTokenizer.tokenizer
    label: ""
    allowUnknownTags: false
    source: (word, searchFunc) ->
      $.ajax
        url: "/search_languages"
        data:
          keyword: word
        success: (response) ->
          currentWords = inputTokenizer.tokenizer('get')

          serverWords = response.languages

          wordsWithoutDuplication = []

          for word in serverWords
            if !(word in currentWords)
              wordsWithoutDuplication.push word

          searchFunc(wordsWithoutDuplication)
    callback: (input) ->
      $("#language_names").val(input.tokenizer('get'));

  for word in currentLanguages
    if word.length > 0
      inputTokenizer.tokenizer('push', word.trim())