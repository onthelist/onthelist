window.$PAGE ?= {}
window.$PAGE.get_arg = ->
  reg = /^[^#]*((\#[^\?]*)?(\?(.*))?)?$/
  matches = reg.exec document.location.toString()

  arg = matches[4]
  return arg

