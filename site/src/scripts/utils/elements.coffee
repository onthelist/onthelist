window.$$ = (node) ->
  data = $(node).data("$$")
  if not data
    data = {}
    $(node).data("$$", data)

  return data

