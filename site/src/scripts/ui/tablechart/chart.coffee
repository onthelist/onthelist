window.$TC ?= {}

class $TC.Chart extends $U.Evented
  constructor: (@cont, @opts={}) ->
    super

    @sprites = []

    @opts.name ?= 'Default Chart'
    @opts.key ?= @opts.name.toLowerCase().remove(' ')

    @editable = @opts.editable ? false
  
    do @load

  _load_occupancy: ->
    $D.parties.bindBack 'change:occupancy add', (row) =>
      occ = row.get 'occupancy'
      if occ?
        if occ.chart == @opts.key
          table = @get_sprite occ.table

          if table?
            table.occupy row
          else
            $.log "No table"

      true

    $D.parties.bind 'remove', (row) =>
      occ = row.get 'occupancy'
      if occ?
        if occ.chart == @opts.key
          table = @get_sprite occ.table

          if table?
            table.occupy null

      true

  get_sprite: (key) ->
    for sprite in @sprites
      if key == sprite.opts.key
        return sprite

    return null

  load: ->
    $.when( $D.charts.init() ).then =>
      $D.charts.get @opts.key, (row) =>
        if row
          @unpack row.sprites

        do @_load_occupancy

  save: ->
    obj = $.extend {}, @opts,
      sprites: do @pack
    
    $.when( $D.charts.init() ).then =>
      $D.charts.add obj

  set_editable: (editable=true) ->
    if @editable == editable
      return

    @editable = editable
    for sprite in @sprites
      if @editable
        $TC.draggable_sprite(sprite, this)
        @trigger 'unlocked'
      else
        do $$(sprite).draggable_sprite.destroy
        @trigger 'locked'

  add: (sprite, type) ->
    if type?
      props =
        opts: sprite
        type: type

      sprite = @create props

    @sprites.push sprite

    if @editable
      $TC.draggable_sprite(sprite, this)
    
    @trigger 'add', [sprite]

    return sprite

  live: (evt, func) ->
    if evt == 'add'
      for sprite in @sprites
        func(false, sprite)

    @bind(evt, func)

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

    @trigger 'remove', [sprite, this]

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
