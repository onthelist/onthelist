class $TC.DraggableSprite
  constructor: (@sprite, @chart) ->
    @modifiers = []

    $.when( @sprite.canvas_ready() ).then =>
      do @init

    @register_modifier @_correct_zoom
    @register_modifier @_shift_scroll
    @register_modifier @_snap

  register_modifier: (func) ->
    @modifiers.push func

  _drag: (ui) ->
    for m in @modifiers
      m.call(this, ui, @sprite.canvas)

  _get_center: (ui) ->
    p = ui.position

    return {
      top: p.top + @$canvas.outerHeight() / 2
      left: p.left + @$canvas.outerWidth() / 2
    }

  _snap: (ui) ->
    THRESHOLD = 5

    p = ui.position
    c = @_get_center ui

    @_snap_lines ?= []

    _draw_line = (x1, y1, x2, y2) =>
      WIDTH = 4

      $line = $('<div></div>')
      $line.addClass('snap-guide ui-bar-b')
      $line.css('position', 'absolute')

      if x1 == x2
        $line.css('left', Math.min(x1, x2) - WIDTH / 2)
        $line.css('top', Math.min(y1, y2))
        $line.css('width', WIDTH)
        $line.css('height', Math.abs(y2 - y1))
      else
        $line.css('left', Math.min(x1, x2))
        $line.css('top', Math.min(y1, y2) - WIDTH / 2)
        $line.css('height', WIDTH)
        $line.css('width', Math.abs(x2 - x1))

      $(@chart.cont).append $line

      @_snap_lines.push $line

    _clear_lines = =>
      for $line in @_snap_lines
        do $line.remove

      @_snap_lines = []

    do _clear_lines

    @$canvas.bind 'dragstop', _clear_lines

    x_pos = y_pos = x_diff = y_diff = null
    for sprite in @chart.sprites
      if sprite == @sprite
        continue

      if sprite.x + THRESHOLD > c.left and sprite.x - THRESHOLD < c.left
        diff = Math.abs(sprite.x - c.left)

        if not x_diff? or diff < x_diff
          x_pos = sprite.x
          x_diff = diff

      if sprite.y + THRESHOLD > c.top and sprite.y - THRESHOLD < c.top
        diff = Math.abs(sprite.y - c.top)

        if not y_diff? or diff < y_diff
          y_pos = sprite.y
          y_diff = diff

    if x_pos? or y_pos?
      x_min = x_max = c.left
      y_min = y_max = c.top

      for sprite in @chart.sprites
        if sprite == @sprite
          continue

        if x_pos and Math.abs(sprite.x - x_pos) < 2
          if sprite.y < y_min
            y_min = sprite.y
          if sprite.y > y_max
            y_max = sprite.y

        if y_pos and Math.abs(sprite.y - y_pos) < 2
          if sprite.x < x_min
            x_min = sprite.x
          if sprite.x > x_max
            x_max = sprite.x

      if x_pos
        p.left += x_pos - c.left
        _draw_line(x_pos, y_min, x_pos, y_max)

      if y_pos
        p.top += y_pos - c.top
        _draw_line(x_min, y_pos, x_max, y_pos)

  _correct_zoom: (ui) ->
    p = ui.position
    o = ui.originalPosition
    p.top = o.top + (p.top - o.top) * 1/$TC.scroller.scale
    p.left = o.left + (p.left - o.left) * 1/$TC.scroller.scale

  _shift_scroll: (ui) ->
    p = ui.position

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

    @sprite._update_pos(p.left, p.top)

  init: ->
    @$canvas = $ @sprite.canvas

    @$canvas.draggable(
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
    .bind('drag', (e, ui) =>
      @_drag ui
    )
    .bind('dragstop', (e, ui) =>
      do @sprite._update_evt
    )
