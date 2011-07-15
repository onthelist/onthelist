window.$F.date =
  format_elapsed: (min, long=false) ->
    out = ''
    if min > 59
      out += (Math.floor min / 60) + 'h '
      min %= 60

      if min
        out += min + 'm'

    else
      out = min + ' ' + if long then 'minutes' else 'min'

    return out

