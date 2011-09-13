#window = module.exports
$DRAW = window.$DRAW ?= {}

$DRAW.cart_to_polar = (e) ->
  ang = Math.atan2((e.y1 - e.y2), (e.x2 - e.x1))

  rad = Math.sqrt(Math.pow(e.y2 - e.y1, 2) + Math.pow(e.x2 - e.x1, 2))

  while ang > 2*Math.PI
    ang -= 2*Math.PI

  while ang < 0
    ang += 2*Math.PI

  if rad == 0
    ang = 0

  return [ang, rad]

$DRAW.rounded_poly = (cxt, points, radius=15) ->
  edges = []
  for i in [0...points.length]
    c_pnt = points[i]
    n_pnt = points[(i + 1) % points.length]

    edges.push
      x1: c_pnt.x
      y1: c_pnt.y
      x2: n_pnt.x
      y2: n_pnt.y

  do cxt.beginPath

  segments = []
  for c_edge in edges
    [ang, rad] = $DRAW.cart_to_polar c_edge

    rad = Math.min radius, rad / 2

    segments.push
      x1: c_edge.x1 + Math.cos(ang) * rad
      y1: c_edge.y1 - Math.sin(ang) * rad
      x2: c_edge.x2 - Math.cos(ang) * rad
      y2: c_edge.y2 + Math.sin(ang) * rad

  cxt.moveTo segments.first().x1, segments.first().y1
  for i in [0...segments.length]
    e = edges[i]
    c = segments[i]
    n = segments[(i + 1) % segments.length]

    [ang, rad] = $DRAW.cart_to_polar c

    if rad < radius * 2
      cxt.lineTo c.x2, c.y2
    else
      cnt_x = (c.x2 + c.x1) / 2
      cnt_y = (c.y2 + c.y1) / 2

      if Math.abs(c.x2 - c.x1) < Math.abs(c.y2 - c.y1)
        cnt_y = Math.max(c.y2, c.y1)
      else
        cnt_x = Math.max(c.x2, c.x1)

      norm = ang + Math.PI / 2
#      cnt_x -= Math.cos(norm) * rad / 10
#      cnt_y -= Math.sin(norm) * rad / 10

      cxt.quadraticCurveTo cnt_x, cnt_y, c.x2, c.y2

    cxt.quadraticCurveTo e.x2, e.y2, n.x1, n.y1

  do cxt.closePath
