window.$IO ?= {}

$IO.build_req = (props) ->
  $.extend props,
    device_id: $ID

  return JSON.stringify props

$IO.make_req = (opts) ->
  $.ajax opts
