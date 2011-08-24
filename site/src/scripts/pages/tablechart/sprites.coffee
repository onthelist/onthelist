styles =
  default:
    fill:
      color: '#F9F9F9'
    line:
      color: '#555'
      width: 2
    label:
      color: '#777'
    shadow:
      x_offset: 0
      y_offset: 0
      blur: 0
      color: 'white'
  empty: {}
  selected:
    line:
      color: 'gold'
    shadow:
      blur: 10
      color: 'rgba(250, 250, 0, 1)'
  aligned:
    line:
      color: '#5393C5'
    shadow:
      blur: 10
      color: '#85BAE4'
  seat:
    fill:
      color: '#DDD'
    line:
      color: '#555'

for own name, style of styles
  if name != 'default'
    styles[name] = $.extend(true, {}, styles['default'], styles[name])

get_style = (name) ->
  return styles[name]

window.$TC ?= {}

class $TC.Sprite extends $U.Evented
  constructor: (@opts) ->
    super

    @ready = $.Deferred()

    if not @opts.key?
      @opts.key = Math.floor(Math.random() * 10000000000000)

  canvas_ready: ->
    return @ready.promise()

  init: (@parent) ->
    @canvas = document.createElement 'canvas'
    @parent.appendChild @canvas
    @cxt = @canvas.getContext '2d'

    @$canvas = $(@canvas)

    $$(@canvas).sprite = this
    
    @w = @h = 0

    @ready.resolve this

    @style_stack = ['default']

    @__defineGetter__ 'style_name', =>
      return @style_stack[@style_stack.length - 1]

  push_style: (name) ->
    if @style_name != name
      @style_stack.push(name)

      do @refresh

  pop_style: ->
    if @style_stack.length > 1
      @style_stack.pop()

      do @refresh

  package: ->
    @opts.x = @x
    @opts.y = @y
    @opts.seats = @seats

    return {opts: @opts}

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

  move: (x, y, corner=false) ->
    if corner
      x = x + @w / 2
      y = y + @h / 2

    @y = y ? @y
    @x = x ? @x
    do @_move

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
    @occupancy = {}

    super @opts

  _apply_style: (name) ->
    @style = get_style(name)

    @cxt.fillStyle = @style.fill.color
    @cxt.strokeStyle = @style.line.color
    @cxt.strokeWidth = @style.line.width

    if @style.shadow?
      @cxt.shadowOffsetX = @style.shadow.x_offset
      @cxt.shadowOffsetY = @style.shadow.y_offset
      @cxt.shadowBlur = @style.shadow.blur
      @cxt.shadowColor = @style.shadow.color
  
  _apply_text_style: (name, elem) ->
    @text_style = get_style(name)[elem]

    @cxt.fillStyle = @text_style.color
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

  draw_label: (margin=[0,0,0,0], style='default', scale_bbox=true) ->
    label = @opts.label
    if not label?
      return

    if typeof label != 'string'
      label = label.toString()

    do @cxt.save
    @_apply_style 'default'
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

    this._draw_circle center, center, rad, @style_name

    square = @w / 2 - rad / Math.sqrt(2)

    @draw_label([square, square, square, square], @style_name, false)

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
      this._draw_rect 0, 0, width, height, @style_name

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

      this._draw_rect @seat_depth, 0, width, height, @style_name

    margin = [0, 0, 0, 0]
    if @seats & 1
      margin[2] = @seat_depth
    if @seats > 1
      margin[1] = margin[3] = @seat_depth

    @draw_label(margin, @style_name)

  rotate: (delta) ->
    super(delta)

    @opts.rotation %= 180
