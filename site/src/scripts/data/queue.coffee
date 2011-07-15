class Queue
  constructor: (@ds) ->
    @ds.each (row) =>
      @register_row row

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
      $(this).trigger('rowRemove', row.key || row)

  get: (args...) ->
    return @ds.get(args...)

  find: (filter, res) ->
    #  Find isn't actually implemented in Lawnchair, so we fake it
    out = []
    @ds.all (rows) ->
      res (row for row in rows when filter(row))

  register_row: (row) ->
    $(this).trigger('rowAdd', row)

$ ->
  new Lawnchair 'queue', (queue_ds) ->
    $D.queue = new Queue queue_ds
    $($D).trigger('queue.ready', [window.$D.queue])
    
    queue_ds.each (row) ->
      # DOM adaptor doesn't seem to support find
      if Date.get_elapsed(row.add_time) > 60 * 2
        queue_ds.remove row

    queue_ds.all (rows) ->
      if rows.length < 12
        fnames = ['John', 'Jane', 'Zack', 'Marshall', 'Dick']
        lnames = ['Smith', 'Bloom', 'Wright', 'Miller', 'Lombardi']

        name = fnames[Math.floor(Math.random() * 5)] + ' ' +
          lnames[Math.floor(Math.random() * 5)]

        size = Math.ceil(Math.random() * 12)
        time = Math.floor(Math.random() * 90)

        $D.queue.add
          key: queue_ds.uuid()
          name: name
          size: size
          add_time: (new Date).add(-time).minutes()
          phone: '2482298031'
          quoted_wait: 60
          alert_method: 'sms'
          status: 'waiting'
          notes: ''
