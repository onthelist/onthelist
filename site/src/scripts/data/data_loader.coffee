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
          @register_row @_wrap_row row

    return @ready.promise()
  
  remove: (row) ->
    if typeof row == 'string'
      @ds.get row, (data) =>
        @remove data
      return

    @ds.remove row, =>
      @trigger 'rowRemove', row

  add: (vals={}) ->
    @ds.save vals, (resp) =>
      @register_row @_wrap_row resp

  save: (vals) ->
    if vals.save?
      do vals.save
    else
      @get vals.key, (data) =>
        if data
          @remove vals

        @add vals

  get: (id, func) ->
    @ds.get id, (data) =>
      func @_wrap_row data

  find: (filter, res) ->
    #  Find isn't actually implemented in Lawnchair, so we fake it
    out = []
    @ds.all (rows) =>
      res (@_wrap_row(row) for row in rows when filter(row))

  register_row: (row) ->
    @trigger('rowAdd', row)

  live: (evt, func) ->
    if @ds? and evt.indexOf 'row' == 0
      # We call the func on all the existing rows with evt of false
      # to allow the event to be bound after the data is initially loaded
      @ds.each (row) =>
        func(false, @_wrap_row row)

    @bind(evt, func)

  _wrap_row: (row) ->
    if @model
      return new @model row, @

    return row

class $D._DataRow extends $U.Evented
  constructor: (data, @coll) ->
    super

    @_extend data

  _extend: (data) ->
    $.extend @, data

  fetch: (cb) ->
    @coll.get @key, (data) =>
      @_extend data
      cb && cb(@)

  save: ->
    data = {}
    for own name, val of @
      if name.substring(0, 1) != '_' and typeof val != 'function'
        data[name] = val

    @coll.remove data
    @coll.add data

