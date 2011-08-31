window.$M ?= {}

$M.send_sms = (to, body, opts={}) ->
  data = $IO.build_req
    to: to
    body: body

  $.extend opts,
    type: 'POST'
    url: '/messaging/send/sms'
    data: data

  $IO.make_req opts

$M.make_call = (to, body, opts={}) ->
  data = $IO.build_req
    to: to
    body: body

  $.extend opts,
    type: 'POST'
    url: '/messaging/send/phone'
    data: data

  $IO.make_req opts
