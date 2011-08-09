styles =
  empty:
    fill_color: '#F9F9F9'
    line_color: '#555'
    label:
      fill_color: '#777'
  seat:
    fill_color: '#DDD'
    line_color: '#555'

window.$TC ?= {}

class $TC.Sprite
  constructor: (@opts) ->

  init: (@parent) ->
    self = this

    @canvas = document.createElement 'canvas'
    @parent.appendChild @canvas
    @cxt = @canvas.getContext '2d'

    @$canvas = $(@canvas)

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
      .bind('dragstop', (e, ui) =>
        do @_update_evt
      )

    @w = @h = 0

  package: ->
    @opts.x = @x
    @opts.y = @y
    @opts.seats = @seats
    return @opts

  destroy: ->
    if @$canvas
      do @$canvas.remove

  _update_evt: ->
    if @parent
      $(@parent).trigger 'spriteUpdate', [this]

  update: ->
    do @_update_evt
    do @refresh

  refresh: ->
    if @cxt and @parent
      @cxt.clearRect(0, 0, @w, @h)
      do @draw

  draw: (parent) ->
    if not @parent? or (parent? and @parent != parent)
      @init parent

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

  constructor: (@opts) ->
    @x = opts.x ? 0
    @y = opts.y ? 0
    @seats = @opts.seats

    super @opts

  _apply_style: (name) ->
    @style = styles[name]

    @cxt.fillStyle = @style.fill_color
    @cxt.strokeStyle = @style.line_color

  _apply_text_style: (name, elem) ->
    @text_style = styles[name][elem]

    @cxt.fillStyle = @text_style.fill_color
    @cxt.font = @text_style.font ? 'bold 1.6em sans-serif'

  draw: (parent) ->
    super parent

    rot = @opts.rotation ? 0
    @$canvas.css('-moz-transform', "rotate(#{rot}deg)")
    @$canvas.css('-moz-transform-origin', "middle center")
    
    do @_move
    do @_draw

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

  _draw_centered_text: (text, x, y, max_width, max_height, scale_bbox=true) ->
    @cxt.textAlign = 'center'
    @cxt.textBaseline = 'middle'

    @cxt.translate(x, y)
    if @opts.rotation
      @opts.rotation %= 360

      # We want text to always remain upright, so we must correct
      # for the canvas rotation.
      rot = @opts.rotation / (180 / Math.PI)
      @cxt.rotate(-rot)

      if scale_bbox and @opts.rotation != 180
        # We must adjust the bounding box after the rotation.

        if @opts.rotation % 90 == 0
          [max_height, max_width] = [max_width, max_height]

        else
          # We find the size of an upright box with the height / width ratio
          # similar to that of the text.
          hyp = max_width
      
          char_ratio = 3 / (text.length * 2.5)

          ang = Math.atan(char_ratio)
          max_height = Math.sin(ang) * hyp
          max_width = Math.cos(ang) * hyp

    if max_height < 30
      size = max_height * .8
    else
      size = 30

    @cxt.font = "bold #{size}px sans-serif"

    @cxt.fillText(text, 0, 0, max_width)

  _draw_fill_text: (text, top, left, w, h) ->
    @cxt.textAlign = 'left'
    @cxt.textBaseline = 'top'

    # The height scaling is an approximation, there is no
    # good way to get the font height.
    @cxt.font = "bold #{h*1.3}px sans-serif"

    @cxt.fillText(text, left, top, w)

  draw_label: (margin=[0,0,0,0], style='empty', scale_bbox=true) ->
    label = @opts.label
    if not label?
      return

    if typeof label != 'string'
      label = label.toString()

    do @cxt.save
    @_apply_text_style style, 'label'

    width = @w - margin[1] - margin[3]
    height = @h - margin[0] - margin[2]

    if @text_style.text_fit == 'fill'
      @_draw_fill_text(label, margin[0], margin[3], width, height)
    else
      cx = width / 2 + margin[3]
      cy = height / 2 + margin[0]

      @_draw_centered_text(label, cx, cy, width, height, scale_bbox)

    do @cxt.restore

  rotate: (delta) ->
    @opts.rotation ?= 0
    @opts.rotation += delta

# Do NOT try to do anything in the constructor of the specific table
# types, the constructor will not be called when the table's shape
# is changed.
class $TC.RoundTable extends $TC.Table
  _draw: ->
    circ = @seats * (@seat_width + @seat_spacing)
    rad = circ / Math.PI / 2

    rad = Math.max(rad, 12)

    center = rad + @seat_depth

    this.size 2*center, 2*center

    ang = 0
    for i in [0...@seats]
      ang += (2*Math.PI / @seats)

      x = Math.cos(ang) * rad + center
      y = Math.sin(ang) * rad + center

      this._draw_seat x, y, ang

    this._draw_circle center, center, rad

    square = @w / 2 - rad / Math.sqrt(2)

    @draw_label([square, square, square, square], 'empty', false)

  rotate: ->

class $TC.RectTable extends $TC.Table
  width: 28
  single_width: 20

  _draw: ->
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

    margin = [0, 0, 0, 0]
    if @seats & 1
      margin[2] = @seat_depth
    if @seats > 1
      margin[1] = margin[3] = @seat_depth

    @draw_label(margin)

  rotate: (delta) ->
    super(delta)

    @opts.rotation %= 180

class $TC.MutableTable
  constructor: (@opts) ->
    @shape = @opts.shape ? 'round'
    
    do @_extend

    obj = do @_get_obj
    obj.call(this, @opts)


  _get_obj: ->
    switch @shape
      when 'round' then $TC.RoundTable
      when 'rect' then $TC.RectTable

  change_shape: (@shape) ->
    do @_extend

  _extend: ->
    obj = do @_get_obj

    if 'change_shape' not of obj.prototype
      obj.prototype = $.extend({}, $TC.MutableTable.prototype, obj.prototype)

    this.__proto__ = obj.prototype
