scroll = null

styles =
  empty:
    fill_color: '#F9F9F9'
    line_color: '#555'
  seat:
    fill_color: '#DDD'
    line_color: '#555'


class Sprite
  constructor: (@parent) ->
    @canvas = document.createElement 'canvas'
    @parent.appendChild @canvas
    @cxt = @canvas.getContext '2d'

    $(@canvas).draggable()
      .bind('touchstart mousedown', ->
        scroll.enabled = false
        true
      )
      .bind('touchend mouseup', ->
        scroll.enabled = true
        true
      )

    @w = @h = 0

  draw: ->

  _move: ->
    y = @y - @h / 2
    x = @x - @w / 2
    @canvas.style.top = y + 'px'
    @canvas.style.left = x + 'px'

  size: (@w, @h) ->
    @canvas.width = @w
    @canvas.height = @h

    do this._move

class Table extends Sprite
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

class RoundTable extends Table
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


class RectTable extends Table
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

get_page_space = ($page) ->
  $content = $page.children(".ui-content")
  hh = $page.children(".ui-header").outerHeight(); hh = hh ? hh : 0
  fh = $page.children(".ui-footer").outerHeight(); fh = fh ? fh : 0
  pt = parseFloat($content.css("padding-top"))
  pb = parseFloat($content.css("padding-bottom"))
  wh = window.innerHeight

  height = wh - (hh + fh) - (pt + pb)

  width = window.innerWidth

  return [width, height]

BASE_HEIGHT = 720.0
BASE_WIDTH = 1280.0

$ ->
  $('#tablechart').live 'pagecreate', ->
    tci = $('.tablechart-inner', this)[0]

    y = 100
    x = 0

    (new RoundTable(tci, 1, x += 100, y)).draw()
    (new RoundTable(tci, 2, x += 100, y)).draw()
    (new RoundTable(tci, 6, x += 100, y)).draw()
    (new RoundTable(tci, 12, x += 100, y)).draw()
    (new RoundTable(tci, 24, x += 100, y)).draw()

    y += 100
    x = 0

    (new RectTable(tci, 1, x += 100, y)).draw()
    (new RectTable(tci, 2, x += 100, y)).draw()
    (new RectTable(tci, 3, x += 100, y)).draw()
    (new RectTable(tci, 4, x += 100, y)).draw()
    (new RectTable(tci, 6, x += 100, y)).draw()
    (new RectTable(tci, 9, x += 100, y)).draw()

  $('#tablechart').live 'pageshow', ->
    $this = $ this
    $tc = $('.tablechart', this)
    $tci = $('.tablechart-inner', this)
    $content = $('.ui-content', this)

    update_size = =>
      # The JQM css sets page min-height based on the landscape and portrait 
      # classes.
      # 
      # Even if we override the min-height on the page, it still follows the
      # overrode properties, so we [unfortunatly] have to get rid of those
      # classes on the page to completly remove the min-height on this page.
      $('html').removeClass 'landscape portrait'

      # ELEMENTS:
      #
      # content
      #   - set to size of visible space, overflow hidden [clipping layer]
      #   tablechart
      #     - set to size of scaled chart, the 'canvas' which is scrolled
      #     tablechart-inner
      #       - set to 1280 x 720, but scaled with css to set the 'default'
      #         zoom based on the size of the screen.
      
      [width, height] = get_page_space $this

      # All the chart coords are based on 1280 x 720
      x_fact = width / BASE_WIDTH
      y_fact = height / BASE_HEIGHT

      max_fact = Math.max(x_fact, y_fact)
      min_fact = Math.min(x_fact, y_fact)

      if min_fact > 0.5
        fact = min_fact
        center = true
      else
        fact = max_fact
        center = false

      # JQ won't set the experimental props using '.css'.
      $tci.attr('style', "-webkit-transform:scale(#{fact}, #{fact});-moz-transform:scale(#{fact}, #{fact});")

      if center
        # If the screen is large enough to show the chart at, at least, 50%
        # scale, we scale it to the larger dimention and center the other.
        if min_fact == y_fact
          $tci.css('left', (width - fact * BASE_WIDTH) / 2.0 + 'px')
        else
          $tci.css('top', (height - fact * BASE_HEIGHT) / 2.0 + 'px')
      
      # The scaling will shrink the chart, but not the space allocated
      # for it, the content area forms a clip to prevent scrolling.
      $content.height height + 'px'

      $tc.height (BASE_HEIGHT * fact) + 'px'
      $tc.width (BASE_WIDTH * fact) + 'px'

    do update_size

    $win = $(window)
    $win.bind 'resize', update_size

    $win.bind 'beforepageshow', ->
      $win.unbind 'resize', update_size

    $(document).bind 'touchmove', (e) ->
      do e.preventDefault
    
    opts =
      lockDirection: false
      hScrollbar: true
      zoom: true
      zoomMax: 6

    scroll = new iScroll $content[0], opts

#    $('#item').bind 'mousedown', ->
#      return false
#    $('#item').draggable()


