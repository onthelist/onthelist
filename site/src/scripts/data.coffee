$$ = (node) ->
  data = $(node).data("$$")
  if not data
    data = {}
    $(node).data("$$", data)

  return data

class Queue
  constructor: (@elem, @ds) ->
    self = $$(@elem).queue = this

    @ds.each (row) ->
      self.register_row row

  add: (name, size, add_time=(new Date)) ->
    self = this

    doc =
      'name': name,
      'size': size,
      'add_time': add_time

    @ds.save(doc, (resp) ->
      self.register_row resp
    )

  register_row: (row) ->
    @elem.trigger('rowAdd', row)

get_elapsed = (date) ->
  if typeof date == 'string'
    date = Date._parse date
  else
    date = date.getTime()

  return Math.floor(((new Date).getTime() - date) / 60000.0)

format_elapsed = (min) ->
  out = ''
  if min > 59
    out += (Math.floor min / 60) + 'h '
    min %= 60

    if min
      out += min + 'm'

  else
    out = min + ' min'

  return out

add_list_row = (elem, row) ->
  elem = $ elem

  el = $ '<li></li>'
  link = $ '<a></a>'
  link.attr('href', '#modify-party')
  el.append link

  elapsed = get_elapsed row.add_time
  e_time = $ '<span class="time">' + format_elapsed(elapsed) + '</span>'
  e_time.attr('data-minutes', elapsed)
  link.append e_time

  name = row.name
  link.append name

  size = row.size

  e_size = $ '<span class="ui-li-count"></span>'
  e_size.text size
  link.append e_size

  elem.after el

  if $('#queue-list').jqmData 'listview'
    $('#queue-list').listview 'refresh'

$ ->
  new Lawnchair 'queue', (queue_ds) ->
    q_elem = $('#queue-list')

    q_elem.bind 'rowAdd', (e, row) ->
      elapsed = get_elapsed row.add_time

      last = null
      q_elem.children('li').each (i, elem) ->
        if elem.getAttribute('data-place') == 'false'
          # If it's a divider, we also won't place beyond it:
          return (elem.getAttribute('data-role') != 'list-divider')

        end = null
        if elem.getAttribute('data-role') == 'list-divider'
          start = parseInt(elem.getAttribute('data-start')) || 0
        else
          start = parseInt $('.time', elem).attr 'data-minutes'

        if elapsed < start
          return false

        last = elem

      add_list_row(last, row)

    queue = new Queue(q_elem, queue_ds)

    queue_ds.all (rows) ->
      if rows.length < 12
        fnames = ['John', 'Jane', 'Zack', 'Marshall', 'Dick']
        lnames = ['Smith', 'Bloom', 'Wright', 'Miller', 'Lombardi']

        name = fnames[Math.floor(Math.random() * 5)] + ' ' +
          lnames[Math.floor(Math.random() * 5)]

        size = Math.ceil(Math.random() * 12)
        time = Math.floor(Math.random() * 90)

        queue.add(name, size, (new Date).add(-time).minutes())
        


