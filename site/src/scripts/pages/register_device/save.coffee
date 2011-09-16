$ ->
  $page = $('#register_device')

  $page.bind 'pageshow', ->
    $page.find('[autofocus]').focus()

  $('form', $page).bind 'submit', (e) ->
    do e.preventDefault
    do e.stopPropagation

    $TRACK.track 'register-device'

    $IO.register_device(
      {
        auth:
          username: $page.find('input[name=username]').val()
          password: $page.find('input[name=password]').val()
        nickname: $page.find('input[name=nickname]').val()
      },
      {
        success: ->
          $page.dialog 'close'
      }
    )
