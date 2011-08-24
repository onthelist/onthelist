get_elapsed = (time) ->
  $F.date.format_elapsed(Date.get_elapsed(time), true)

window.$F.party =
  status: (obj) ->
    switch obj.status
      when 'waiting'
        return "Waiting #{get_elapsed(obj.times.add)}"

      when 'seated'
        return "Seated #{get_elapsed(obj.times.seated)} ago"

    return ''

