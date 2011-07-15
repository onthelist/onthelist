$ ->
  last_title = false
  add_el = false
  cancel_el = false

  show_fake_page = (self) ->
    # Add Dummy List Element
    add_el = $ '<li></li>'
    link = $ '<a></a>'
    add_el.append link

    link.addClass "list-action"
    link.text "Check-In Without Queue"
  
    $('#queue-list').prepend add_el
    $('#queue-list').listview 'refresh'

    # Hide Add Button
    cancel_el = $ '<a></a>'
    cancel_el.attr('href', '#queue')
    cancel_el.addClass 'ui-btn-left'

    $('a[href=#add-party]')
      .hide()
      .before cancel_el

    cancel_el.buttonMarkup
      icon: 'arrow-l'
      iconpos: 'notext'

    cancel_el.click ->
      hide_fake_page self

    do $(self).hide

    last_title = $('.ui-title:visible').text()
    $('.ui-title:visible').text 'Choose a Party'

  hide_fake_page = (self) ->
    do $('a[href=#add-party]').show
    do cancel_el.remove
    do add_el.remove
    do $(self).show

    $('.ui-title:visible').text last_title
    last_title = false

  $('a[href=#check-in]').click (e) ->
    do e.preventDefault

    if last_title
      hide_fake_page this
    show_fake_page this
    
    false

