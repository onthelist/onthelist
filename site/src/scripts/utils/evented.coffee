window.$U ?= {}

class $U.Evented
  constructor: ->
    @evt = $({})

  trigger: (args...) ->
    @evt.trigger(args...)

  live: (evt, func) ->
    @evt.bind(evt, func)

  bind: (args...) ->
    @evt.bind(args...)

