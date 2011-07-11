Date.prototype.setISO8601 = (string) ->
  regexp = "([0-9]{4})(-([0-9]{2})(-([0-9]{2})" +
      "(T([0-9]{2}):([0-9]{2})(:([0-9]{2})(\.([0-9]+))?)?" +
      "(Z|(([-+])([0-9]{2}):([0-9]{2})))?)?)?)?"
  d = string.match(new RegExp(regexp))

  offset = 0
  date = new Date(d[1], 0, 1)

  if d[3]
    date.setMonth(d[3] - 1)
  if d[5]
    date.setDate(d[5])
  if d[7]
    date.setHours(d[7])
  if d[8]
    date.setMinutes(d[8])
  if d[10]
    date.setSeconds(d[10])
  if d[12]
    date.setMilliseconds(Number("0." + d[12]) * 1000)
  if d[14]
    offset = (Number(d[16]) * 60) + Number(d[17])
    offset *= ((d[15] == '-') ? 1 : -1)

  offset -= date.getTimezoneOffset()
  time = (Number(date) + (offset * 60 * 1000))

  this.setTime(Number(time))

Date.get_minutes = (date) ->
  if typeof date == 'string'
    (new Date).setISO8601(date)
  else
    date.getTime()

Date.get_elapsed = (date) ->
  date = Date.get_minutes date

  return Math.floor(((new Date).getTime() - date) / 60000.0)

Date.format_elapsed = (min, long=false) ->
  out = ''
  if min > 59
    out += (Math.floor min / 60) + 'h '
    min %= 60

    if min
      out += min + 'm'

  else
    out = min + ' ' + if long then 'minutes' else 'min'

  return out

