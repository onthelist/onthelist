window.$F.date =
  format_elapsed: (min, long=false) ->
    out = ''
    if min > 59
      out += (Math.floor min / 60) + 'h '
      min %= 60

      if min
        out += Math.floor(min) + 'm'

    else
      out = Math.floor(min) + ' ' + if long then 'minutes' else 'min'

    if min < 1
      out = Math.floor(min * 60) + ' sec'

    return out

  format_remaining: (min, plus=true, sec=false) ->
    str = ''
      
    if plus and min > 0
      str = '+'

    if sec and min < 1 and min > 0
      return str + (Math.floor(min * 60) + 1) + ' sec'
    else
      return str + Math.floor(min) + ' min'

