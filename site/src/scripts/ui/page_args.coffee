window.$PAGE ?= {}
window.$PAGE.get_arg = ->
  reg = /^[^#]*((\#[^\?]*)?(\?(.*))?)?$/

  loc = document.location.toString()
  loc = loc.replace $.mobile.dialogHashKey, ''

  matches = reg.exec loc

  arg = matches[4]
  return arg

