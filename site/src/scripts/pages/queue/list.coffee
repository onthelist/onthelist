window.$QUEUE ?= {}
$QUEUE.show_view_page = (key) ->
  $TRACK.track 'view-party-from-queue'

  $$('#queue-list').selected_key = key
  window.location = '#view-party'

save_row_key = ->
  $$('#queue-list').selected_key = this.getAttribute 'data-id'

add_list_row = (list, row) ->
  el = $ '<li></li>'

  el.addClass row.status.join(' ')
  row.bind 'status:change', (e, status, prev) ->
    el.removeClass prev.join(' ')
    el.addClass status.join(' ')

  link = $ '<a></a>'
  link.attr('href', '#view-party')
  link.attr('data-id', row.key)
  link.bind 'vclick', save_row_key

  el.append link

  elapsed = Date.get_elapsed row.times.add
  e_time = $ '<time>' + $F.date.format_elapsed(elapsed) + '</time>'
  e_time.attr('data-minutes', elapsed)
  e_time.attr('datetime', row.times.add)
  e_time.attr('data-format', $S.queue.time_view)

  if row.quoted_wait
    qw = parseInt row.quoted_wait

    e_time.attr('data-target', qw)

  link.append e_time

  e_name = $('<span></span>')
  e_name.attr('data-key', 'name')
  e_name.text row.name
  link.append e_name

  size = row.size

  for i in [1..size]
    e_slice = $ '<span class="ui-li-count slice">1</span>'
    e_slice.css 'right', (38 + 2 * (size - i)) + 'px'
    link.append e_slice

  e_size = $ '<span class="ui-li-count" data-key="size"></span>'
  e_size.text size
  link.append e_size

  link.swipe_menu
    actions:
      [
        label: 'Alert'
        theme: 'e'
        cb: ->
          $TRACK.track 'swipe-alert'
          $IO.alert row,
            status_on:
              success: false
              progress: false
      ,
        label: 'Check-In'
        cb: ->
          $TRACK.track 'swipe-check-in'
          $QUEUE.check_in row.key
      ]

  list.insert el, elapsed

$ ->
    q_elem = $('#queue-list')

    list = q_elem.queueList $S.queue

    $('#queue').bind 'pageshow', ->
      do list.add_dynamics

      $$(q_elem).selected_key = undefined

      # DEMO
      $('.ui-input-search input').bind 'keyup', ->
        if $(this).val() == 'DEMO'
          do $D.parties.demo
        else if $(this).val() == 'CLEAR'
          do $D.parties.clear
        else
          return

        $(this).val ''

    q_elem.bind 'heightChange', ->
      $.fixedToolbars.show(true)

    $('#queue').bind 'optionChange', (e, name, val) ->
      $S.queue[name] = val
      do $S.save

      $TRACK.track 'queue-option-change',
        name: name
        val: val

      switch name
        when 'sort' then list.sort val
        when 'group' then list.group val
        when 'time_view' then q_elem.find('time').time 'toggle_format'

    $D.parties.live 'rowAdd', (e, row) ->
      if not row.status.has 'waiting'
        return

      elapsed = Date.get_elapsed row.times.add

      add_list_row(list, row)

    $D.parties.bind 'rowRemove', (e, row) ->
      if list
        list.remove($('a[data-id=' + row.key + ']', q_elem).parents('li').first())
    
