window.$F.party =
  status: (obj) ->
    switch obj.status
      when 'waiting'
        wait_time = $F.date.format_elapsed(Date.get_elapsed(obj.add_time), true)
        return "Waiting #{wait_time}"

      when 'seated'
        return "Seated"

    return ''

