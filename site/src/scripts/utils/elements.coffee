window.$$ = (node) ->
  data = $(node).jqmData("$$")
  if not data
    data = {}
    $(node).jqmData("$$", data)

  return data

