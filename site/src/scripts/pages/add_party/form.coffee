$ ->
  $('#add-party').bind 'pagecreate', ->
    $('.ui-input-text', this).each (i, el) ->
      $el = $(el)
      if $el.val()
        $el.attr('data-default', $el.val())

  $('#add-party').bind 'pageshow', ->
    $('.ui-input-text', this).each (i, el) ->
      $el = $(el)
      $el.val($el.attr('data-default') ? '')

    $('.ui-input-text', this).first().focus()

  $('#add-party a[href=#add]').bind 'vclick', (e) ->
    dia = $ '#add-party'

    vals =
      name: $('[name=name]', dia).val()
      size: $('[name=party_size]', dia).val()
      phone: $('[name=phone_number]', dia).val()
      quoted_wait: $('[name=wait_time]', dia).val()
      seating_pref: $('[name=seating_preference]', dia).val()
      called_ahead: $('[name=called_ahead]', dia).val()
      alert_method: $('[name=alert_method]', dia).val()
      notes: $('[name=notes]', dia).val()

    $D.queue.add(vals)

    dia.dialog 'close'

    false
