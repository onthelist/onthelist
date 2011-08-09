window.$TC ?= {}

class $TC.Chart
  constructor: (@cont, @opts={}) ->
    @sprites = []

    if not @opts.name
      @opts.name = 'Default Chart'

    if not @opts.key
      @opts.key = @opts.name.toLowerCase().remove(' ')
  
    do @load

  load: ->
    $.when( $D.charts.init() ).then =>
      $D.charts.get @opts.key, (row) =>
        if row
          @unpack row.sprites

  save: ->
    obj = $.extend {}, @opts,
      sprites: do @pack
    
    $.when( $D.charts.init() ).then =>
      $D.charts.add obj

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
    do @clear

    for entry in data
      # Note that sprites must be elements of $TC
      cls = $TC[entry.type]
      sprite = new cls(entry.opts)

      @add sprite

    do @draw
