class $D._DataLoader
  constructor: ->
    @evt = $({})
  
    @ready = $.Deferred()
    @initing = false

  init: ->
    if not @initing and not @ds?
      @initing = true
     
      new Lawnchair @name, (ds) =>
        @initing = false
        @ds = ds
        
        @ready.resolve this

        @ds.each (row) =>
          @register_row row

    return @ready.promise()
  
  remove: (row) ->
    @ds.remove row, =>
      @evt.trigger('rowRemove', row.key || row)

  add: (vals={}) ->
    @ds.save vals, (resp) =>
      @register_row resp

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


