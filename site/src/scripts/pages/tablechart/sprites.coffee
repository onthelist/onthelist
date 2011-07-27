styles =
  empty:
    fill_color: '#F9F9F9'
    line_color: '#555'
  seat:
    fill_color: '#DDD'
    line_color: '#555'

window.$TC ?= {}

class $TC.Sprite
  constructor: (@parent) ->
    self = this

    @canvas = document.createElement 'canvas'
    @parent.appendChild @canvas
    @cxt = @canvas.getContext '2d'

    $$(@canvas).sprite = this

    offset =
      top: 0
      left: 0

    selected = $([])

    $(@canvas).draggable(
      opacity: 0.5
      containment: 'parent'
    )
      .bind('touchstart mousedown', ->
        $TC.scroller.enabled = false
        true
      )
      .bind('touchend mouseup mouseout', ->
        $TC.scroller.enabled = true
        true
      )
      .bind('drag', (e, ui) ->
        # We have to correct for the zoom level.
        p = ui.position
        o = ui.originalPosition
        p.top = o.top + (p.top - o.top) * 1/$TC.scroller.scale
        p.left = o.left + (p.left - o.left) * 1/$TC.scroller.scale

        # Shift the scroll area to keep the scrolled elem visible.
        $content = $('.ui-page-active .ui-content')
        [width, height] = [$content.width(), $content.height()]

        s = $TC.scroller
        x_shift = y_shift = 0
        if -s.x > p.left
          x_shift = -(p.left + s.x)
        else if width - s.x < p.left
          x_shift = -(p.left - (width - s.x))
        
        if -s.y > p.top
          y_shift = -(p.top + s.y)
        else if height - s.y < p.top
          y_shift = -(p.top - (height - s.y))

        if x_shift or y_shift
          s.scrollTo(s.x + x_shift, s.y + y_shift, 0)

        p.top -= y_shift * $TC.scroller.scale
        p.left -= x_shift * $TC.scroller.scale

        self._update_pos(p.left, p.top)
      )
      .bind('dragstart', (e, ui) ->
        $this = $ this

        #selected = $('.ui-selected').each ->
        #  $el = $ this
        #  $el.data 'offset', $el.offset()
        
        #if not $this.hasClass 'ui-selected'
        #  $this.addClass 'ui-selected'

        #offset = $this.offset()
      )
      .bind('drag', (e, ui) ->
        dt = ui.position.top - offset.top
        dl = ui.position.left - offset.left

        selected.not(this).each ->
          $el = $(this)
          offset = $el.data("offset")

        #  $el.css
        #    top: offset.top + dt
        #    left: offset.left + dl
      )

    @w = @h = 0

  refresh: ->
    @cxt.clearRect(0, 0, @w, @h)
    do @draw

  draw: ->

  _move: ->
    y = @y - @h / 2
    x = @x - @w / 2
    @canvas.style.top = y + 'px'
    @canvas.style.left = x + 'px'

  _update_pos: (x, y) ->
    @x = x + @w / 2
    @y = y + @h / 2

  size: (@w, @h) ->
    @canvas.width = @w
    @canvas.height = @h

    do this._move

class $TC.Table extends $TC.Sprite
  seat_width: 10
  seat_depth: 7
  seat_spacing: 3

  constructor: (@parent, @seats, @x=0, @y=0) ->
    super(@parent)

    do this._move

  _apply_style: (name) ->
    style = styles[name]

    @cxt.fillStyle = style.fill_color
    @cxt.strokeStyle = style.line_color

  _draw_circle: (x, y, rad, style='empty') ->
    this._apply_style style

    do @cxt.beginPath
    @cxt.arc x, y, rad, 0, Math.PI*2, true
    do @cxt.closePath

    do @cxt.fill
    do @cxt.stroke

  _draw_seat: (x, y, rot=0) ->
    # The coords represent the middle of the lower straight line.
    do @cxt.save
    this._apply_style 'seat'

    @cxt.translate x, y
    @cxt.rotate rot + Math.PI / 2

    pan_depth = @seat_depth - @seat_width / 2
    
    do @cxt.beginPath
    
    # Move to upper left corner
    @cxt.moveTo (-@seat_width / 2), (-pan_depth)

    # Lower left
    @cxt.lineTo (-@seat_width / 2), 0

    # Lower right
    @cxt.lineTo (@seat_width / 2), 0

    # Upper right
    @cxt.lineTo (@seat_width / 2), (-pan_depth)

    # Arc to form back
    @cxt.arc 0, (-pan_depth), (@seat_width / 2), 0, Math.PI, true

    do @cxt.closePath

    do @cxt.fill
    do @cxt.stroke

    do @cxt.restore

  _draw_rect: (x, y, w, h, style='empty') ->
    do @cxt.save
    this._apply_style style

    do @cxt.beginPath

    @cxt.moveTo x, y
    @cxt.lineTo (x+w), y
    @cxt.lineTo (x+w), (y+h)
    @cxt.lineTo x, (y+h)

    do @cxt.closePath

    do @cxt.fill
    do @cxt.stroke

    do @cxt.restore

class $TC.RoundTable extends $TC.Table
  draw: ->
    circ = @seats * (@seat_width + @seat_spacing)
    rad = circ / Math.PI / 2

    rad = Math.max(rad, 8)

    center = rad + @seat_depth

    this.size 2*center, 2*center

    ang = 0
    for i in [0...@seats]
      ang += (2*Math.PI / @seats)

      x = Math.cos(ang) * rad + center
      y = Math.sin(ang) * rad + center

      this._draw_seat x, y, ang

    this._draw_circle center, center, rad


class $TC.RectTable extends $TC.Table
  width: 28
  single_width: 20

  draw: ->
    width = if @seats > 1 then @width else @single_width

    side_seats = Math.floor(@seats / 2)

    height = side_seats * (@seat_width + @seat_spacing) + @seat_spacing

    height = Math.max(height, @seat_width + 2 * @seat_spacing)

    out_width = width
    if @seats > 1
      # Add space for the seats
      out_width += 2 * @seat_depth

    out_height = height
    if @seats & 1
      # There's an odd number of seats (there will be one at the head of 
      # the table)
      out_height += @seat_depth

    this.size out_width, out_height

    if @seats <= 1
      # Single tables are smaller
      this._draw_seat (width / 2), height, Math.PI / 2
      this._draw_rect 0, 0, width, height

    else

      seats_left = @seats
      x = @seat_depth
      y = @seat_spacing + @seat_width / 2

      for i in [0...side_seats]
        # Fill in the seats one row at a time, leaving the odd one out
        # [if there is one] for the end.
        seats_left -= 2

        this._draw_seat x, y, Math.PI
        this._draw_seat x + width, y, 0

        y += @seat_width + @seat_spacing

      if seats_left
        # Put the extra seat at the head of the table
        this._draw_seat (@seat_depth + width / 2), height, Math.PI / 2

      this._draw_rect @seat_depth, 0, width, height

class $TC.MutableTable extends $TC.Table
  constructor: (@parent, @seats, @x=0, @y=0, @shape='round') ->
    obj = do @_get_obj

    obj.call(this, @parent, @seats, @x, @y)

    do @_extend

  _get_obj: ->
    switch @shape
      when 'round' then $TC.RoundTable
      when 'rect' then $TC.RectTable

  change_shape: (@shape) ->
    do @_extend

  _extend: ->
    obj = do @_get_obj

    $.extend(this.__proto__, obj.prototype)

