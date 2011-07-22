$ ->
  $('[data-role=header], [data-role=header] h1').bind 'swipeleft swiperight', (e) ->
    $('body').toggleClass('dark-theme')
