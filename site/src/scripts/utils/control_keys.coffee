window.$CTRL_KEYS = $({})

codes =
  16: 'shift'
  17: 'ctrl'
  18: 'alt'

$(document).keydown (e) ->
  name = codes[e.keyCode]
  if name
    $CTRL_KEYS[name] = true
    $CTRL_KEYS.trigger("#{name}down")

$(document).keyup (e) ->
  name = codes[e.keyCode]
  if name
    $CTRL_KEYS[name] = false
    $CTRL_KEYS.trigger("#{name}up")
