window.$F.party =
  status: (obj) ->
    if not obj.status or obj.status == 'waiting'

      wait_time = $F.date.format_elapsed(Date.get_elapsed(obj.add_time), true)
      return "Waiting #{wait_time}"

    return ''

