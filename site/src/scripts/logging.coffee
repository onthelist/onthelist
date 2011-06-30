REMOTE_LOGGING = true

$.log = (args...) ->
  if window and window.console and window.console.log
    console.log args...

  if REMOTE_LOGGING
    try
      $.ajax
        url: '/log/console'
        type: 'POST'
        data:
          args: args
    catch e
      false
