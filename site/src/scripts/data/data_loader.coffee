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
          if not row._deleted
            @register_row @_wrap_row row

    return @ready.promise()
  
  remove: (row, prev_row) ->
    if typeof row == 'string'
      @ds.get row, (data) =>
        @remove data
      return

    $IO.sync.del @model_name ? @model?.name, row.key

    row._deleted = true

    @incr_rev row

    @_save row, =>
      @trigger 'rowRemove', [row, prev_row ? row]

  _save: (row, cb=->) ->
    if row.clean_data?
      row = do row.clean_data

    @ds.save row, cb

  add: (vals={}) ->
    @incr_rev vals

    @_save vals, (resp) =>
      @register_row @_wrap_row resp

      @push_row vals.key

    return vals.key

  push_row: (key) ->
    @ds.get key, (vals) =>
      rev = vals._rev
      $IO.sync.push @model_name ? @model?.name, vals, (resp) =>
        if resp.ok
          @ds.get key, (nvals) =>
            if nvals._rev == rev
              # It was not changed since we pushed
              nvals._rev = resp.rev
              @_save nvals

  update: (vals) ->
    @incr_rev vals
    @_save vals, =>
      @push_row vals.key

  sync: ->
    name = @model_name ? @model?.name

    $IO.sync.pull name, undefined, (data) =>
      d = {}
      for row in data.rows
        d[row.key] = row

      @ds.each (row) =>
        if not d[row.key]?
          # It's not on the server

          if row?._deleted
            # Really delete now that the delete is synced
            @ds.remove row.key

          else
            $IO.sync.push name, row.key, row

        else
          # It's here and on the server
          d[row.key]._visited = true
          
          if not row._changed
            # It hasen't been changed here
            if row._rev == d[row.key]._rev
              # It hasen't been changed there
              return

            else
              @save d[row.key], false
          else
            if row._deleted
              # It was deleted here.
              $IO.sync.del name, row.key

            else
              # Conflict
              $.log 'conflict', row, d[row.key]

      for own key, row of d
        if row._visited
          continue

        # It's not on here yet.
        @_save row, (resp) =>
          @register_row @_wrap_row resp

  incr_rev: (vals) ->
    @_changed = true

    if not vals._rev?
      vals._rev = "1-#{@ds.uuid()}"

  _trigger_replace: (vals) ->
    @get vals.key, (data) =>
      if data
        @trigger 'rowRemove', vals

      @trigger 'rowAdd', vals

  save: (vals, mark_changed=true) ->
    if mark_changed
      @incr_rev vals

    if vals.save?
      return vals.save undefined, mark_changed
    else
      @_save vals, =>
        @_trigger_replace vals

    return vals.key

  get: (id, func) ->
    @ds.get id, (data) =>
      func @_wrap_row data

  find: (filter, res) ->
    #  Find isn't actually implemented in Lawnchair, so we fake it
    out = []
    @ds.all (rows) =>
      res (@_wrap_row(row) for row in rows when filter(row) and not row._deleted)

  register_row: (row) ->
    @trigger('rowAdd', row)

  live: (evt, func) ->
    if @ds? and evt.indexOf 'row' == 0
      # We call the func on all the existing rows with evt of false
      # to allow the event to be bound after the data is initially loaded
      ids = []
      @ds.each (row) =>
        if row._deleted
          return

        if row.key in ids
          return

        ids.push row.key
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

  clean_data: ->
    data = {}
    for own name, val of @
      if name in ['_rev', '_changed', '_deleted'] or (name.substring(0, 1) != '_' and typeof val != 'function')
        data[name] = val

    return data

  save: (replace=true, mark_changed=true) ->
    if mark_changed
      @_coll.incr_rev @

    data = do @clean_data

    @_coll.update data, @_prev_data

    if replace
      @_coll._trigger_replace data
    
    @_prev_data = data

    return data.key
