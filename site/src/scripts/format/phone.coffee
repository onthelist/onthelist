window.$F.phone = (d) ->
  pre = d[0..2]
  reg = d[3..5]
  cod = d[6..]

  return "(#{pre}) #{reg}-#{cod}"
