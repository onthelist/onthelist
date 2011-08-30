$ ->
  $page = $('#register_device')

  $('a[href=#register]', $page).bind 'vclick', (e) ->
    do e.preventDefault

    $IO.register_device(
      {
        auth:
          username: $page.filter('input[name=username]').val()
          password: $page.filter('input[name=password]').val()
        nickname: $page.filter('input[name=nickname]').val()
      },
      {
        success: ->
          $page.dialog 'close'
      }
    )
