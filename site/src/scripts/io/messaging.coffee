window.$M ?= {}

$M.send_sms = (to, body) ->
  $.ajax
    type: 'POST'
    url: '/messaging/send/sms'
    data:
      to: to
      body: body

$M.make_call = (to, body) ->
  $.ajax
    type: 'POST'
    url: '/messaging/send/phone'
    data:
      to: to
      body: body
