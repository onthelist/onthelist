# A tweaked version of the JUI selectable widget to properly handle
# the helper box and selection when working with our scaled tablechart.

get_fixed_margin = ->
  $cont = $($TC.chart.cont)

  offset = $cont.offset()
  scaled_margin = $cont.position()

  return {
    top: offset.top - scaled_margin.top
    left: offset.left - scaled_margin.left
  }

window.$TC ?= {}
$TC.scale_page_coords = (x, y) ->
  # The top and left css attrs of the container are scaled when it is scaled,
  # but the fixed margins on the page (e.g. the header) are not, so we must
  # ignore them when calculating the scaling.
  
  fixed_margin = do get_fixed_margin

  y -= fixed_margin.top
  x -= fixed_margin.left
  
  x *= 1/$TC.scroller.scale
  y *= 1/$TC.scroller.scale

  y += fixed_margin.top
  x += fixed_margin.left

  x += -$TC.scroller.x
  y += -$TC.scroller.y

  return [x, y]

$TC.scale_rel_coords = (x, y) ->
  fixed_margin = do get_fixed_margin

  y -= fixed_margin.top
  x -= fixed_margin.left
  
  x *= $TC.scroller.scale
  y *= $TC.scroller.scale

  y += fixed_margin.top
  x += fixed_margin.left

  x -= -$TC.scroller.x
  y -= -$TC.scroller.y

  return [x, y]

$.widget "ui.scaled_selectable", $.ui.selectable,
  options: $.ui.selectable.prototype.options
  _mouseStart: (evt) ->
    [evt.pageX, evt.pageY] = $TC.scale_page_coords(evt.pageX, evt.pageY)

    return $.ui.selectable.prototype._mouseStart.call(this, evt)

  _mouseDrag: (evt) ->
    [evt.pageX, evt.pageY] = $TC.scale_page_coords(evt.pageX, evt.pageY)
    
    [x1, y1] = this.opos
    [x2, y2] = [evt.pageX, evt.pageY]

    ret = $.ui.selectable.prototype._mouseDrag.call(this, evt)

    if x1 > x2
      [x1, x2] = [x2, x1]
    if y1 > y2
      [y1, y2] = [y2, y1]

    [x1, y1] = $TC.scale_rel_coords(x1, y1)
    [x2, y2] = $TC.scale_rel_coords(x2, y2)
    @helper.css {
      left: x1
      top: y1
      width: (x2-x1)
      height: (y2-y1)
    }

    return ret
