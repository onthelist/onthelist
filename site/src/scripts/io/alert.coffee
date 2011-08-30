window.$IO ?= {}

$IO.alert = (data) ->
  if data.alert_method == 'sms'
    $M.send_sms(data.phone, 'Your table is ready! Please visit the host stand to be seated.')
  else if data.alert_method == 'call'
    $M.make_call(data.phone, 'Your table is ready! Please visit the host stand to be seated.')