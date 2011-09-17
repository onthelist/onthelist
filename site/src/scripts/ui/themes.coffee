$ ->
  if $S.look?.theme == 'dark'
    $('body').addClass('dark-theme')

  $('[data-role=header], [data-role=header] h1').bind 'swipeleft swiperight', (e) ->
    $('body').toggleClass('dark-theme')

    $S.look ?= {}
    $S.look.theme = (if $('body').hasClass('dark-theme') then 'dark' else 'light')
    do $S.save
