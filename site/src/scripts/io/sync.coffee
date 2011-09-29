$IO ?= {}
class Syncer
  constructor: ->
    @queue = []

  _push: (type, data, key=data.key ? "default#{type}") ->
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

  push: (attrs...) ->
    @queue.push ['push', attrs]
    do @process_queue

  del: (attrs...) ->
    @queue.push ['del', attrs]
    do @process_queue

  process_queue: ->
    # Process the queue when the active process is done.
    if not @to?
      @to = setTimeout(@_process_queue, 1000)

  _process_queue: =>
    @to = null

    for act in @queue
      task = act[0]
      args = act[1]

      @["_#{task}"].call(this, args...)

    @queue = []

$IO.sync = new Syncer
