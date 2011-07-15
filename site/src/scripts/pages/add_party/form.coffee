$ ->
  $('#add-party a[href=#add]').live 'vclick', (e) ->
    do e.preventDefault
    do e.stopPropagation

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

    $$('#queue-list').queue.add(vals)

    $.log 'close'
    dia.dialog 'close'
    $.log 'ed'

    false
