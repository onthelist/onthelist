$(document).bind 'swipeleft', ->
  $('body').removeClass('dark-theme')

$(document).bind 'swiperight', ->
  $('body').addClass('dark-theme')
