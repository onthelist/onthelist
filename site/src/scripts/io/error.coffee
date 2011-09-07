$ ->
  $('body').ajaxError (e, req, opts) ->
    if req?.status == 402
      document.location = '#register_device'
