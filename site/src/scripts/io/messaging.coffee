window.$M ?= {}

$M.send = (to, body) ->
  $.ajax
    type: 'POST'
    url: '/messaging/send/sms'
    data:
      to: to
      body: body
