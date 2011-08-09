window.$TC ?= {}

class $TC.Chart
  constructor: (@cont) ->
    @sprites = []

  add: (sprite) ->
    @sprites.push sprite

  clear: ->
    for sprite in @sprites
      do sprite.destroy

    @sprites = []

  draw: ->
    for sprite in @sprites
      sprite.draw @cont

  pack: ->
    out = []
    for sprite in @sprites
      out.push
        opts: sprite.package()
        type: sprite.__proto__.constructor.name

    return out

  unpack: (data) ->
    for entry in data
      # Note that sprites must be elements of $TC
      cls = $TC[entry.type]
      sprite = new cls(entry.opts)

      @add sprite

