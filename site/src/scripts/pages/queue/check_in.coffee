$ ->
  last_title = false
  add_el = false
  cancel_el = false

  $page = $('#queue')
  $list = $('#queue-list', $page)

  window.$QUEUE ?= {}

  $QUEUE.check_in = (id, success, failure) ->
    $TC.choose_table
      success: (table) =>
        $D.queue.remove id

        table.occupancy.occupant = id

        success && success(table)

  _bind_actions = ->
    $links = $list.find('a[href=#view-party]')

    $links.each (i, el) ->
      $el = $ el

      $el.bind 'vclick', ->
        id = $el.attr 'data-id'

        $P.queue.check_in id, ->
          do hide_fake_page

        false

  show_fake_page = (self) ->
    do _bind_actions

    # Add Dummy List Element
    add_list = $ '<ul></ul>'
    add_list.addClass 'pseudo-list'
    
    add_el = $ '<li></li>'
    add_list.append add_el

    link = $ '<a></a>'
    add_el.append link

    link.addClass "list-action"
    link.text "Check-In Without Queue"
  
    $list.before add_list
    add_list.listview()

    # Replace add button with back button
    cancel_el = $ '<a></a>'
    cancel_el.attr('href', '#queue')
    cancel_el.addClass 'ui-btn-left'

    $('a[href=#add-party]', $page)
      .hide()
      .before cancel_el

    cancel_el.buttonMarkup
      icon: 'arrow-l'
      iconpos: 'notext'

    cancel_el.bind 'vclick', ->
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

  $('a[href=#check-in]').bind 'vclick', (e) ->
    do e.preventDefault

    if last_title
      hide_fake_page this
    show_fake_page this
    
    false

