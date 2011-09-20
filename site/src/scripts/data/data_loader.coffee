class $D._DataLoader extends $U.Evented
  constructor: ->
    super

    @ready = $.Deferred()
    @initing = false
    @cache = {}

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
  
  remove: (row, prev_row) ->
    if typeof row == 'string'
      @ds.get row, (data) =>
        @remove data
      return

    $IO.sync.del 'party', row.key

    @ds.remove row, =>
      @trigger 'rowRemove', [row, prev_row ? row]

  add: (vals={}) ->
    @ds.save vals, (resp) =>
      @register_row @_wrap_row resp

    $IO.sync.push 'party', vals

    return vals.key

  update: (vals) ->
    $IO.sync.push 'party', vals

    @ds.save vals

  save: (vals) ->
    if vals.save?
      return do vals.save
    else
      @get vals.key, (data) =>
        if data
          @remove vals

        @add vals

      return vals.key

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
        try
          func(false, @_wrap_row row)
        catch e
          console.log "Error with row", row, e

    @bind(evt, func)

  _wrap_row: (row) ->
    if not @model
      return row

    if not row?
      return row

    if row.key of @cache
      @cache[row.key]._extend row
    else
      @cache[row.key] = new @model row, @

    return @cache[row.key]

  clear: ->
    @ds.each (row) ->
      @remove row

class $D._DataRow extends $U.Evented
  constructor: (data, @_coll) ->
    super

    @_extend data

  _extend: (data) ->
    $.extend @, data

  fetch: (cb) ->
    @_coll.get @key, (data) =>
      @_extend data
      @_prev_data = data

      cb && cb(@)

  save: (replace=true) ->
    data = {}
    for own name, val of @
      if name.substring(0, 1) != '_' and typeof val != 'function'
        data[name] = val

    if replace
      @_coll.remove data, @_prev_data
      @_coll.add data, @_prev_data
    else
      @_coll.update data, @_prev_data

    @_prev_data = data

    return data.key
