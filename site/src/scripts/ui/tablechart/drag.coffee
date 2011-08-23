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

  register_modifier: (func) ->
    @modifiers.push func

  _drag: (ui) ->
    for m in @modifiers
      m.call(this, ui, @sprite.canvas)

  _start: (ui) ->
    for name, prop of this
      if name.startsWith('_start_')
        prop.call(this, ui)

  _stop: (ui) ->
    for name, prop of this
      if name.startsWith('_stop_')
        prop.call(this, ui)

  _move_menu: (ui) ->
    $menu = $ '#tablechart .editor'
    p = ui.position

    if $menu.hasClass('docked-left') and p.left < $menu.width()
      $menu.removeClass 'docked-left'
      $menu.addClass 'docked-right'

    else if $menu.hasClass('docked-right') and p.left > ($(document).width() - $menu.width())
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
      if sprite == @sprite
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
    .bind('dragstart', (e, ui) =>
      if not @$canvas.hasClass 'ui-selected'
        @$canvas.trigger 'select'

      @_start ui
    )
    .bind('dragstop', (e, ui) =>
      do @sprite._update_evt

      @_stop ui
    )

$TC.draggable_sprite = (elem, cont) ->
  $$(elem).draggable_sprite = new DraggableSprite(elem, cont)
