class $TC.DraggableSprite
  constructor: (@elem, @scroller) ->
    @modifiers = []

    do @init

    @register_modifier @_correct_zoom
    @register_modifier @_shift_scroll

  register_modifier: (func) ->
    @modifiers.push func

  _drag: (ui) ->
    for m in @modifiers
      m.call(this, ui, @elem)

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

    @scroller._update_pos(p.left, p.top)

  init: ->
    self = this

    $(@elem).draggable(
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
        do @scroller._update_evt
      )
