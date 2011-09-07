$ ->
  $page = $('#register_device')

  $('a[href=#register]', $page).bind 'vclick', (e) ->
    do e.preventDefault
    do e.stopPropagation

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
