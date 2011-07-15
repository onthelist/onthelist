save_row_key = ->
  $$('#queue-list').selected_key = this.getAttribute 'data-id'

add_list_row = (list, row) ->
  el = $ '<li></li>'
  link = $ '<a></a>'
  link.attr('href', '#view-party')
  link.attr('data-id', row.key)
  link.bind 'vclick', save_row_key

  el.append link

  elapsed = Date.get_elapsed row.add_time
  e_time = $ '<time>' + $F.date.format_elapsed(elapsed) + '</time>'
  e_time.attr('data-minutes', elapsed)
  e_time.attr('datetime', row.add_time)

  if row.quoted_wait
    qw = parseInt row.quoted_wait

    e_time.attr('data-target', qw)

  link.append e_time

  name = row.name
  link.append name

  size = row.size

  for i in [1..size]
    e_slice = $ '<span class="ui-li-count slice">1</span>'
    e_slice.css 'right', (38 + 2 * (size - i)) + 'px'
    link.append e_slice

  e_size = $ '<span class="ui-li-count"></span>'
  e_size.text size
  link.append e_size

  list.insert el, elapsed

$ ->
    q_elem = $('#queue-list')

    list = do q_elem.queueList

    $D.queue.live 'rowAdd', (e, row) ->
      elapsed = Date.get_elapsed row.add_time

      add_list_row(list, row)

    $D.queue.bind 'rowRemove', (e, key) ->
      do $('a[data-id=' + key + ']', this).parents('li').first().remove

      do list.refresh
    
