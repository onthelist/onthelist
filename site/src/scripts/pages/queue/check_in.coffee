$ ->
  last_title = false
  add_el = false
  cancel_el = false

  $page = $('#queue')
  $list = $('#queue-list', $page)

  window.$QUEUE ?= {}

  $QUEUE.check_out = (id, success, failure) ->
    $D.parties.get id, (data) =>
      $.log 'party', data
      if not data?.occupancy?
        failure && do failure
        return

      $TRACK.track 'check-out'

      data.add_status 'left'
      data.times.left = new Date

      data.occupancy = null

      $.log 'save', data
      do data.save

      success && do success

  $QUEUE.check_in = (id, success, failure) ->
    $TC.choose_table
      success: (table) =>
        $D.parties.get id, (data) =>
          if not data?
            $.log 'Party being checked in not found', id
            return

          $TRACK.track 'check-in'

          data.add_status 'seated'

          data.times.seated = new Date

          data.occupancy =
            table: table.opts.key
            chart: $TC.chart.opts.key

          # The TC will be notified of the party change and will update
          # the table.

          do data.save

          success && success(table)

  _action = ->
    $el = $ this

    id = $el.attr 'data-id'

    $TRACK.track 'check-in-from-queue'

    $QUEUE.check_in id, ->
      do hide_fake_page

    false

  _bind_actions = ->
    $links = $list.find('a[href=#view-party]')

    $links.each (i, el) ->
      $(el).bind 'vclick', _action

  _unbind_actions = ->
    $links = $list.find('a[href=#view-party]')

    $links.each (i, el) ->
      $(el).unbind 'vclick', _action

  show_fake_page = ->
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
    link.attr 'href', '#'
    link.bind 'vclick', (e) ->
      do e.stopPropagation
      do e.preventDefault

      party =
        'status': ['waiting']
        'name': 'Quick Check In'

      $TRACK.track 'check-in-wo-party'

      key = $D.parties.add(party)
      $QUEUE.check_in key, ->
        do hide_fake_page
  
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
      do hide_fake_page

    do $(CHECK_IN_BTN).hide

    last_title = $('.ui-title:visible').text()
    $('.ui-title:visible').text 'Choose a Party'

  hide_fake_page = ->
    do $('a[href=#add-party]').show
    do cancel_el.remove
    do add_el.remove
    do $(CHECK_IN_BTN).show

    do _unbind_actions

    $('.ui-title:visible').text last_title
    last_title = false

  CHECK_IN_BTN = null
  $('a[href=#check-in]').bind 'vclick', (e) ->
    do e.preventDefault

    $TRACK.track 'queue-check-in-click'

    CHECK_IN_BTN = this
    if last_title
      do hide_fake_page
    do show_fake_page
    
    false

