window.$IO ?= {}

$IO.register_device = (props, opts) ->
  props.device = $D.device.attributes

  data = $IO.build_req props

  success = opts.success
  opts.success = (data) ->
    if data and data.ok
      $D.device.registered = true
      $D.device.set data.device

      do $D.device.save

      success && success data

    else
      opts.error && opts.error data

  $.extend opts,
    url: '/device/register'
    type: 'POST'
    data: data
    contentType: 'application/json'
  
  $IO.make_req opts
