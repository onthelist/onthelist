window.$U ?= {}

class $U.Evented
  constructor: ->
    @_evt = $({})

  trigger: (args...) ->
    @_evt.trigger(args...)

  live: (evt, func) ->
    @_evt.bind(evt, func)

  bind: (args...) ->
    @_evt.bind(args...)

