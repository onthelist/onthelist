$.extend $.Isotope.prototype,
  _timelineReset: ->
    @_timeline = {}
    
  _timelineLayout: ($elems) ->
    _t = @_timeline

    _t.height = 0

    @layoutBy = @options.layoutBy ? @options.sortBy
    order_func = @options.getSortData[@layoutBy]

    _t.elem_width = @options.elementWidth ? 300
    
    min = max = null

    _t.order = []
    for elem in $elems
      order = order_func(elem)

      if not min or order < min
        min = order
      if not max or order > max
        max = order

      elem.setAttribute('data-order', order)

    _t.width = @element.width()
    _t.scale = (_t.width - _t.elem_width) / (max - min)
    _t.minimum = min

    rows = [[]]

    for elem in $elems
      $elem = $ elem

      $elem.width("#{_t.elem_width}px")

      order = parseFloat elem.getAttribute('data-order')
      x = _t.scale * (order - _t.minimum)

      width = $elem.outerWidth()
      height = $elem.outerHeight() + 2

      i = 0
      row = rows[0]
      while i < rows.length
        row = rows[i]

        blocked = false
        for [st_x, en_x] in row
          if st_x <= x <= en_x or st_x <= x + width <= en_x
            $.log $elem, st_x, en_x, x, x+width
            blocked = true
            break

        if not blocked
          break

        i++
        
      if blocked
        rows.push []
        i = rows.length - 1
        row = rows[i]

      y = i * height

      if y + height > _t.height
        _t.height = y + height

      row.push [x, x + width]

      @_pushPosition $elem, x, y

  _timelineGetContainerSize: ->
    return {
      height: @_timeline.height
    }

  _timelineResizeChanged: ->
    true
