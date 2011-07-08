class Queue
  constructor: (@elem, @ds) ->
    self = $$(@elem).queue = this

    @ds.each (row) ->
      self.register_row row

  add: (name, size, add_time=(new Date)) ->
    self = this

    if typeof add_time != 'string'
      add_time = add_time.toISOString()

    doc =
      'name': name,
      'size': size,
      'add_time': add_time

    @ds.save doc, (resp) ->
      self.register_row resp

  remove: (row) ->
    self = this

    @ds.remove row, ->
      self.elem.trigger('rowRemove', row.key || row)

  get: (args...) ->
    return @ds.get(args...)

  register_row: (row) ->
    @elem.trigger('rowAdd', row)


save_row_key = ->
  $$('#queue-list').selected_key = this.getAttribute 'data-id'

add_list_row = (list, row) ->
  el = $ '<li></li>'
  link = $ '<a></a>'
  link.attr('href', '#view-party')
  link.attr('data-id', row.key)
  link.click save_row_key

  el.append link

  elapsed = Date.get_elapsed row.add_time
  e_time = $ '<time>' + Date.format_elapsed(elapsed) + '</time>'
  e_time.attr('data-minutes', elapsed)
  e_time.attr('datetime', row.add_time)
  link.append e_time

  name = row.name
  link.append name

  size = row.size

  e_size = $ '<span class="ui-li-count"></span>'
  e_size.text size
  link.append e_size

  list.insert el, elapsed

$ ->
  new Lawnchair 'queue', (queue_ds) ->
    q_elem = $('#queue-list')

    list = do q_elem.queueList

    q_elem.bind 'rowAdd', (e, row) ->
      elapsed = Date.get_elapsed row.add_time

      add_list_row(list, row)

    q_elem.bind 'rowRemove', (e, key) ->
      do $('a[data-id=' + key + ']', this).parents('li').first().remove

      do list.refresh
  
    queue_ds.each (row) ->
      # DOM adaptor doesn't seem to support find
      if Date.get_elapsed(row.add_time) > 60 * 2
        queue_ds.remove row

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
