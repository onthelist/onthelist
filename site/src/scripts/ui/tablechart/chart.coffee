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
      $D.charts.add obj

  set_editable: (editable=true) ->
    if @editable == editable
      return

    @editable = editable

    @trigger if @editable then 'unlocked' else 'locked'

    for sprite in @sprites
      if sprite.draggable == false
        continue

      if @editable
        $TC.draggable_sprite(sprite, this)
      else
        do $$(sprite).draggable_sprite.destroy

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

    @trigger 'draw'

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
