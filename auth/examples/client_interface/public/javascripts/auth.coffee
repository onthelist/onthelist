show = (data) -> $('body').append($('<div></div>').text(JSON.stringify(data)))
err = (req) -> $('body').append($('<div></div>').css('color', 'red').text(req.responseText))

$ -> 
  $('#create-account').submit (evt) ->
    evt.preventDefault()

    username = $('input[name=username]', this).val()
    password = $('input[name=password]', this).val()

    $.ajax(
      url: '/account'
      data:
        username: username
        password: password
      type: 'POST'
      error: err
      success: show
    )
        
  $('#login').submit (evt) ->
    evt.preventDefault()

    username = $('input[name=username]', this).val()
    password = $('input[name=password]', this).val()

    $.ajax(
      url: '/_session'
      data:
        username: username
        password: password
      type: 'POST'
      error: err
      success: show
    )

  $('a[href=#logout]').click (evt) ->
    evt.preventDefault()

    $.ajax(
      url: '/_session'
      type: 'DELETE'
      error: err
      success: show
    )

  $('a[href=#get_user]').click (evt) ->
    evt.preventDefault()

    $.ajax(
      url: '/_session/user'
      error: err
      success: show
    )

