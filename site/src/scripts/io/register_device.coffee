window.$IO ?= {}

$IO.register_device = (props={}, opts={}) ->
  props.device = $D.device.attributes

  data = $IO.build_req props

  opts.beforeSuccess = (d) ->
    $D.device.set d.device
    do $D.device.save

    return d

  $.extend opts,
    url: '/device/register'
    type: 'POST'
    data: data
  
  $IO.make_req opts

$IO.fetch_device = (opts={}) ->
  data = do $IO.build_req

  opts.beforeSuccess = (d) ->
    $D.device.set d.device
    do $D.device.save

    return d

  opts.beforeError = (d, status, err_text) ->
    if err_text == 'Not Found'
      $D.device.attributes.registered = false
      $D.device.save()

    return [d, status, err_text]

  $.extend opts,
    type: 'POST'
    url: '/device/'
    data: data

  $IO.make_req opts
