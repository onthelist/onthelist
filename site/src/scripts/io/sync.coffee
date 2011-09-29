$IO ?= {}
class Syncer
  constructor: ->
    @queue = {}

  _push: (type, key, data) ->
    type = type.toLowerCase()

    props = {}
    props[type] = data

    props = $IO.build_req props

    req =
      data: JSON.stringify props
      type: 'POST'
      url: "/sync/#{type}/#{key}"

    $IO.make_req req

  pull: (type, key="", cb=->) ->
    type = type.toLowerCase()

    props = $IO.build_req {}

    req =
      data: props
      type: 'GET'
      url: "/sync/#{type}/#{key}"
      success: (data) ->
        if not data?.ok
          $.log "Bad pull response", data
          return

        cb data

    $IO.make_req req

  _del: (type, key) ->
    type = type.toLowerCase()

    props = $IO.build_req
      _method: 'delete'

    req =
      type: 'POST'
      data: props
      url: "/sync/#{type}/#{key}"

    $IO.make_req req

  push: (type, data, key=data.key) ->
    @queue[type + '::' + key] = data
    do @process_queue

  del: (type, key) ->
    @queue[type + '::' + key] = null
    do @process_queue

  process_queue: ->
    # Process the queue when the active process is done.
    if not @to?
      @to = setTimeout(@_process_queue, 1000)

  _process_queue: =>
    @to = null

    for own lbl, data of @queue
      if data is null
        task = 'del'
      else
        task = 'push'

      [type, key] = lbl.split '::'

      @["_#{task}"].call(this, type, key, data)

    @queue = []

$IO.sync = new Syncer
