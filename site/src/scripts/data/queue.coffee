class Queue
  constructor: ->
    @evt = $({})

    @ready = $.Deferred()
    @initing = false

  init: ->
    if not @initing and not @ds?
      @initing = true
      
      new Lawnchair 'queue', (ds) =>
        @initing = false
        @ds = ds
        
        @ready.resolve this

        @ds.each (row) =>
          @register_row row

    return @ready.promise()

  add: (vals={}) ->
    '''
    Passed values: name, size, add_time, ...
    '''
    vals.add_time ?= new Date
    if typeof vals.add_time != 'string'
      vals.add_time = vals.add_time.toISOString()

    @ds.save vals, (resp) =>
      @register_row resp

  remove: (row) ->
    @ds.remove row, =>
      @evt.trigger('rowRemove', row.key || row)

  get: (args...) ->
    return @ds.get(args...)

  find: (filter, res) ->
    #  Find isn't actually implemented in Lawnchair, so we fake it
    out = []
    @ds.all (rows) ->
      res (row for row in rows when filter(row))

  register_row: (row) ->
    @evt.trigger('rowAdd', row)

  live: (evt, func) ->
    if @ds? and evt.indexOf 'row' == 0
      # We call the func on all the existing rows with evt of false
      # to allow the event to be bound after the data is initially loaded
      @ds.each (row) ->
        func(false, row)

    @evt.bind(evt, func)

  bind: (args...) ->
    @evt.bind(args...)

$D.queue = new Queue
$.when( $D.queue.init() ).then ->
  
  $D.queue.ds.each (row) ->
    # DOM adaptor doesn't seem to support find
    if Date.get_elapsed(row.add_time) > 60 * 2
      $D.queue.ds.remove row

  $D.queue.ds.all (rows) ->
    len = rows.length
    while len++ < 12
      fnames = ['John', 'Jane', 'Zack', 'Marshall', 'Dick']
      lnames = ['Smith', 'Bloom', 'Wright', 'Miller', 'Lombardi']

      name = fnames[Math.floor(Math.random() * 5)] + ' ' +
        lnames[Math.floor(Math.random() * 5)]

      size = Math.ceil(Math.random() * 12)
      time = Math.floor(Math.random() * 90)

      notes = ['Requests a quiet room', 'Drink: Martini extra olives', '']
      note = notes[Math.floor(Math.random() * 3)]

      $D.queue.add
        key: $D.queue.ds.uuid()
        name: name
        size: size
        add_time: (new Date).add(-time).minutes()
        phone: '2482298031'
        quoted_wait: 60
        alert_method: 'sms'
        status: 'waiting'
        notes: note

      break
