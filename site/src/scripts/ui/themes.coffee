$ ->
  $('[data-role=header]').bind 'swipeleft swiperight', (e) ->
    $('body').toggleClass('dark-theme')
