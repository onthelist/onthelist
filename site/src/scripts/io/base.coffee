window.$IO ?= {}

$IO.build_req = (props={}) ->
  $.extend props,
    device_id: $ID

  return props

$IO.make_req = (opts) ->
  if opts.beforeSuccess?
    success = opts.success
    opts.success = (data) ->
      if data and data.ok
        ret = opts.beforeSuccess data

        success && success(ret)
      else
        opts.error && opts.error data

  if opts.beforeError?
    error = opts.error
    opts.error = (data, status, err_text) ->
      ret = opts.beforeError data, status, err_text

      error && error(ret...)

  if opts.type == 'POST'
    opts.contentType = 'application/json'

    if typeof opts.data != 'string'
      opts.data = JSON.stringify opts.data

  $.ajax opts
