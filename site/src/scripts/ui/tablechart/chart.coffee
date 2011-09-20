window.$TC ?= {}

class $TC.Chart extends $U.Evented
  constructor: (@cont, @opts={}) ->
    super

    @sprites = []

    @section_sets = {}
    @current_section_set = 'default'
    
    @__defineGetter__ "sections", =>
      return @section_sets[@current_section_set]
    @__defineSetter__ "sections", (val) =>
      @section_sets[@current_section_set] = val

    @sections = {}

    @opts.name ?= 'Default Chart'
    @opts.key ?= @opts.name.toLowerCase().remove(' ')

    @editable = @opts.editable ? false
  
    do @load

  _load_occupancy: ->
    $.when( $D.parties.init() ).then =>
      $D.parties.live 'rowAdd', (e, row) =>
        if row.occupancy
          if row.occupancy.chart == @opts.key
            table = @get_sprite row.occupancy.table

            if table?
              table.occupy row
            else
              $.log "No table"

        true

      $D.parties.bind 'rowRemove', (e, row, prev_row) =>
        if prev_row.occupancy
          if prev_row.occupancy.chart == @opts.key
            table = @get_sprite prev_row.occupancy.table

            if table?
              table.occupy null

        true

  get_sprite: (key) ->
    for sprite in @sprites
      if key == sprite.opts.key
        return sprite

    return null

  get_section: (sprite) ->
    key = sprite.opts.key ? sprite

    for own k, sec of @sections
      if key in sec.tables
        return sec

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
      $D.charts.update obj

    do @_push

  _push: ->
    do_push = =>
      obj = $.extend {}, @opts,
        sprites: do @pack

      $IO.sync.push 'chart', obj

    if @_push_to?
      clearTimeout @_push_to

    @_push_to = setTimeout do_push, 5000

  _set_sprite_editable: (sprite) ->
    if sprite.draggable == false
      return

    if @editable
      $TC.draggable_sprite(sprite, this)
    else
      do $$(sprite).draggable_sprite.destroy

  set_editable: (editable=true) ->
    if @editable == editable
      return

    @editable = editable

    @trigger if @editable then 'unlocked' else 'locked'

    for sprite in @sprites
      @_set_sprite_editable sprite

  add: (sprite, type) ->
    if type?
      props =
        opts: sprite
        type: type

      sprite = @create props

    @sprites.push sprite
    if sprite.is_section
      @sections[sprite.opts.key] = sprite

    if @editable and sprite.draggable != false
      $TC.draggable_sprite(sprite, this)
    
    @trigger 'add', [sprite]

    sprite.draw @cont

    return sprite

  next_section_color: ->
    cnts = {}
    for color in Object.keys($TC.Section.prototype.colors)
      cnts[color] = 0
    for own key, section of @sections
      cnts[section.opts.color] += 1

    arr = ([col, cnt] for own col, cnt of cnts)
    arr.sortBy (c) ->
      c[1]

    return arr[0][0]

  refresh_sections: ->
    for own key, section of @sections
      do section.refresh

  get_section: (sprite) ->
    for own key, section of @sections
      if sprite.opts.key in section.tables
        return section

    return null

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

    @_set_sprite_editable n_spr
    @trigger 'add', n_spr

    return n_spr

  draw: ->
    for sprite in @sprites
      sprite.draw @cont

    @trigger 'draw'

  pack: ->
    out = []
    for sprite in @sprites
      obj = sprite.package()

      if not obj.type
        obj.type = sprite.proto

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
      try
        sprite = @create entry
        @add sprite
      catch e
        console.log "Error loading sprite", data, e

    do @draw
