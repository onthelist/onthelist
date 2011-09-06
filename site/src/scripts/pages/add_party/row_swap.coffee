$ ->
  $('#add-party').bind 'pagecreate', ->
    $name = $('[name=name]', this)
    $phone = $('[name=phone]', this)

    phone_first = true
    swap = ->
      $name_cont = $name.parents('.ui-field-contain').first()
      $phone_cont = $phone.parents('.ui-field-contain').first()

      p_val = $phone.val()
      n_val = $name.val()
      $phone.val n_val
      $name.val p_val

      $name_cont.detach()
      if phone_first
        $name_cont.insertBefore $phone_cont
        $name.focus()
      else
        $name_cont.insertAfter $phone_cont
        $phone.focus()

      phone_first = !phone_first

    $phone.keyup (e) ->
      val = $phone.val()

      c = val.charCodeAt val.length - 1
      if not (97 <= c <= 122 or 65 <= c <= 90 or 48 <= c <= 57)
        # Get rid of special chars.
        $phone.val val.substring(0, val.length - 2)
        return false

      if val.length != 1
        return

      code = val.charCodeAt 0
      if 97 <= code <= 122 or 65 <= code <= 90
        do swap

    $(this).bind 'pageshow', ->
      if not phone_first
        do swap
