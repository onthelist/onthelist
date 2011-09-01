window.$QUEUE ?= {}
$QUEUE.show_view_page = (key) ->
  $$('#queue-list').selected_key = key
  window.location = '#view-party'

save_row_key = ->
  $$('#queue-list').selected_key = this.getAttribute 'data-id'

add_list_row = (list, row) ->
  attr = row.attributes

  el = $ '<li></li>'
  el.addClass attr.status.join(' ')

  link = $ '<a></a>'
  link.attr('href', '#view-party')
  link.attr('data-id', row.id)
  link.bind 'vclick', save_row_key

  el.append link

  elapsed = Date.get_elapsed attr.times.add
  e_time = $ '<time>' + $F.date.format_elapsed(elapsed) + '</time>'
  e_time.attr('data-minutes', elapsed)
  e_time.attr('datetime', attr.times.add)
  e_time.attr('data-format', $S.queue.time_view)

  if attr.quoted_wait
    qw = parseInt attr.quoted_wait

    e_time.attr('data-target', qw)

  link.append e_time

  e_name = $('<span></span>')
  e_name.attr('data-key', 'name')
  e_name.text attr.name
  link.append e_name

  size = attr.size

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
          $IO.alert row
      ,
        label: 'Check-In'
        cb: ->
          $QUEUE.check_in row.id
      ]

  list.insert el, elapsed

$ ->
  q_elem = $('#queue-list')

  list = q_elem.queueList $S.queue

  $('#queue').bind 'pageshow', ->
    do list.add_dynamics

    $$(q_elem).selected_key = undefined

  q_elem.bind 'heightChange', ->
    $.fixedToolbars.show(true)

  $('#queue').bind 'optionChange', (e, name, val) ->
    $S.queue[name] = val
    do $S.save

    switch name
      when 'sort' then list.sort val
      when 'group' then list.group val
      when 'time_view' then q_elem.find('time').time 'toggle_format'

  $D.parties.bindBack 'add', (row) ->
    if not row.get('status').has 'waiting'
      return

    elapsed = Date.get_elapsed row.get('times').add

    add_list_row(list, row)

  $D.parties.bind 'remove', (row) ->
    if list
      list.remove($('a[data-id=' + row.id + ']', q_elem).parents('li').first())
  
