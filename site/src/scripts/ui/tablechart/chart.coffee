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

  add: (sprite, type) ->
    if type?
      props =
        opts: sprite
        type: type

      sprite = @create props

    @sprites.push sprite

    new $TC.DraggableSprite(sprite, this)

    $(@cont).trigger('add', [sprite])

    return sprite

  bind: (args...) ->
    $(@cont).bind(args...)

  clear: ->
    for sprite in @sprites
      do sprite.destroy

    @sprites = []

  _find: (sprite) ->
    for s, i in @sprites
      if s == sprite
        return i

    throw "Sprite not found"

  remove: (sprite) ->
    index = @_find sprite

    do sprite.destroy
    @sprites.removeAt(index)

    do @draw
    do @save

    $(@cont).trigger 'spriteRemoved', [sprite, this]

  change_type: (sprite, dest_type) ->
    index = @_find sprite
    
    props = do sprite.package
    props.type = dest_type

    n_spr = @create props

    do sprite.destroy
    @sprites[index] = n_spr

    do @draw

    return n_spr

  draw: ->
    for sprite in @sprites
      sprite.draw @cont

  pack: ->
    out = []
    for sprite in @sprites
      obj = sprite.package()

      if not obj.type
        obj.type = sprite.__proto__.constructor.name

      out.push obj

    return out

  create: (entry) ->
    # Note that sprites must be elements of $TC
    cls = $TC[entry.type]
    sprite = new cls(entry.opts)

    return sprite

  unpack: (data) ->
    do @clear

    for entry in data
      sprite = @create entry
      @add sprite

    do @draw
