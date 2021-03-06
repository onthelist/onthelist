class DraggableSprite
  constructor: (@sprite, @chart) ->
    @modifiers = []

    $.when( @sprite.canvas_ready() ).then =>
      do @init

    @register_modifier @_correct_zoom
    #@register_modifier @_shift_scroll
    @register_modifier @_snap
    @register_modifier @_include_selected
    @register_modifier @_move_menu
    @register_modifier @_update_pos

  register_modifier: (func) ->
    @modifiers.push func

  _drag: (ui, e) ->
    for m in @modifiers
      m.call(this, ui, @sprite.canvas, e)

  _start: (ui, e) ->
    for name, prop of this
      if name.startsWith('_start_')
        prop.call(this, ui, @sprite.canvas, e)

  _stop: (ui, e) ->
    for name, prop of this
      if name.startsWith('_stop_')
        prop.call(this, ui, @sprite.canvas, e)

  _move_menu: (ui) ->
    $menu = $ '#tablechart .editor'
    p = ui.position

    if $menu.hasClass('docked-left') and p.left * $TC.scroller.scale < $menu.width()
      $menu.removeClass 'docked-left'
      $menu.addClass 'docked-right'

    else if $menu.hasClass('docked-right') and p.left * $TC.scroller.scale > ($(document).width() - $menu.width())
      $menu.removeClass 'docked-right'
      $menu.addClass 'docked-left'

  _start_include_selected: ->
    c = @$canvas.position()
    
    sel = $('.ui-selected', @chart.cont)

    @_include_selected_selection = []

    for elem in sel
      if elem != @sprite.canvas
        @_include_selected_selection.push
          sprite: $$(elem).sprite
          delta:
            left: parseFloat(elem.style.left) - c.left
            top: parseFloat(elem.style.top) - c.top

  _stop_include_selected: ->
    @_include_selected_selection = []

  _include_selected: (ui) ->
    p = ui.position
   
    for rec in @_include_selected_selection
      rec.sprite.move(p.left + rec.delta.left, p.top + rec.delta.top, true)

  _get_center: (ui) ->
    p = ui.position

    return {
      top: p.top + @$canvas.outerHeight() / 2
      left: p.left + @$canvas.outerWidth() / 2
    }

  _snap: (ui) ->
    # Snap dragged elements to align with other elements and even spacing.
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

      if @_snap_matched?
        for sprite in @_snap_matched
          do sprite.pop_style

        @_snap_matched = []

    do _clear_lines
    
    @_snap_matched = []

    @$canvas.bind 'dragstop', _clear_lines

    $TC.gaps = {}

    x_pos = y_pos = x_diff = y_diff = null
    x_list = []
    y_list = []
    for sprite in @chart.sprites
      if sprite == @sprite or sprite.snap == false
        continue

      if sprite.x + THRESHOLD > c.left and sprite.x - THRESHOLD < c.left
        x_list.push sprite.y - c.top
        diff = Math.abs(sprite.x - c.left)

        if not x_diff? or diff < x_diff
          x_pos = sprite.x
          x_diff = diff

      else if sprite.y + THRESHOLD > c.top and sprite.y - THRESHOLD < c.top
        y_list.push sprite.x - c.left
        diff = Math.abs(sprite.y - c.top)

        if not y_diff? or diff < y_diff
          y_pos = sprite.y
          y_diff = diff

      else
        # Don't add the aligned style to sprites which didn't match either
        # criteria.
        continue

      @_snap_matched.push sprite

    if not @_snap_matched.length
      return
    
    @_snap_matched.push @sprite
    for sprite in @_snap_matched
      sprite.push_style 'aligned'

    if x_pos? or y_pos?
      x_min = x_max = c.left
      y_min = y_max = c.top
      x_closest = y_closest = null

      for sprite in @chart.sprites
        if sprite == @sprite
          continue

        if x_pos and Math.abs(sprite.x - x_pos) < THRESHOLD
          if sprite.y < y_min
            y_min = sprite.y
          if sprite.y > y_max
            y_max = sprite.y

          if x_pos != sprite.x
            sprite.move(x_pos, null)

        if y_pos and Math.abs(sprite.y - y_pos) < THRESHOLD
          if sprite.x < x_min
            x_min = sprite.x
          if sprite.x > x_max
            x_max = sprite.x

          if y_pos != sprite.y
            sprite.move(null, y_pos)

      _find_closest_gap = (list) =>
        list.sortBy Math.abs

        closest = list[0]
        second = null
        for l in list.slice(1)
          if (closest >= 0) == (l >= 0)
            second = l
            break

        if not second?
          return [null, null]

        gap = -(second - closest)
        diff = -(-gap - closest)

        return [gap, diff]

      if x_pos
        p.left += x_pos - c.left
        _draw_line(x_pos, y_min, x_pos, y_max)

        if not y_pos
          [y_gap, y_gap_diff] = _find_closest_gap x_list

          if y_gap
            $TC.gaps.y = y_gap
            $TC.gaps.x = 0

            _draw_line(x_pos - 8, c.top + y_gap_diff, x_pos + 8, c.top + y_gap_diff)

           if Math.abs(y_gap_diff) < THRESHOLD
              p.top += y_gap_diff
      
      if y_pos
        p.top += y_pos - c.top
        _draw_line(x_min, y_pos, x_max, y_pos)

        if not x_pos
          [x_gap, x_gap_diff] = _find_closest_gap y_list

          if x_gap
            $TC.gaps.x = x_gap
            $TC.gaps.y = 0

            _draw_line(c.left + x_gap_diff, y_pos - 8, c.left + x_gap_diff, y_pos + 8)

            if Math.abs(x_gap_diff) < THRESHOLD
              p.left += x_gap_diff

  _start_correct_zoom: (ui, cvs, evt) ->
    p = ui.position
    o = ui.originalPosition

    $tci = $('.tablechart-inner')
    tci = $tci[0]

    @_cz_offset = parseFloat(tci.style.left) - $tci.position().left

  _correct_zoom: (ui) ->
    p = ui.position
    o = ui.originalPosition
    p.top = o.top + (p.top - o.top) * 1/$TC.scroller.scale
    p.left = o.left + (p.left - o.left) * 1/$TC.scroller.scale

    if Math.abs(@_cz_offset) > 1
      # Some devices (webkit) scale the inner box's position when reporting
      # coords, we use the offset to detect that, and adjust the positioning.
      p.left += o.left * $TC.scroller.scale
      p.top += o.top * $TC.scroller.scale

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

  _start_update_pos: ->
    @sprite.trigger 'moveStart'

  _update_pos: (ui) ->
    p = ui.position

    @sprite._update_pos(p.left, p.top)

  _stop_update_pos: (ui) ->
    # Allow the sprite's move evt to fire
    do @sprite.move

  destroy: ->
    @$canvas.draggable('destroy')
      .unbind('drag', @_e_drag)
      .unbind('dragstart', @_e_drag_start)
      .unbind('dragstop', @_e_drag_stop)
      .unbind('touchstart mousedown', @_e_mouse_down)
      .unbind('touchend mouseup mouseout', @_e_mouse_up)

  _e_drag: (e, ui) =>
    @_drag ui, e
    
  _e_drag_start: (e, ui) =>
    if not @$canvas.hasClass 'ui-selected'
      @$canvas.trigger 'select'

    @_start ui, e
    
  _e_drag_stop: (e, ui) =>
    do @sprite._update_evt

    @_stop ui, e

  _e_mouse_down: ->
    $TC.scroller.enabled = false
    true

  _e_mouse_up: ->
    $TC.scroller.enabled = true
    true

  init: ->
    @$canvas = $ @sprite.canvas

    @$canvas.draggable(
      opacity: 0.5
      containment: 'parent'
    )
    .bind('touchstart mousedown', @_e_mouse_down)
    .bind('touchend mouseup mouseout', @_e_mouse_up)
    .bind('drag', @_e_drag)
    .bind('dragstart', @_e_drag_start)
    .bind('dragstop', @_e_drag_stop)

$TC.draggable_sprite = (elem, cont) ->
  $$(elem).draggable_sprite = new DraggableSprite(elem, cont)
