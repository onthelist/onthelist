class $D._DataLoader extends $U.Evented
  constructor: ->
    super

    @ready = $.Deferred()
    @initing = false

  init: ->
    if not @initing and not @ds?
      @initing = true
     
      opts =
        name: @name
        record: @name

      new Lawnchair opts, (ds) =>
        @initing = false
        @ds = ds
        
        @ready.resolve this

        @ds.each (row) =>
          @register_row row

    return @ready.promise()
  
  remove: (row) ->
    @ds.remove row, =>
      @trigger('rowRemove', row.key || row)

  add: (vals={}) ->
    @ds.save vals, (resp) =>
      @register_row resp

  save: (vals) ->
    @get vals.key, (data) =>
      if data
        @remove vals

      @add vals

  get: (args...) ->
    return @_wrap_row(@ds.get(args...))

  _wrap_row: (row) ->
    if row? and typeof row == 'object'
      row.update = (cb) =>
        @get row.key, (data) =>
          $.extend(true, row, data)
          cb && cb(row)

    return row

  find: (filter, res) ->
    #  Find isn't actually implemented in Lawnchair, so we fake it
    out = []
    @ds.all (rows) ->
      res (row for row in rows when filter(row))

  register_row: (row) ->
    @trigger('rowAdd', row)

  live: (evt, func) ->
    if @ds? and evt.indexOf 'row' == 0
      # We call the func on all the existing rows with evt of false
      # to allow the event to be bound after the data is initially loaded
      @ds.each (row) ->
        func(false, row)

    @bind(evt, func)
