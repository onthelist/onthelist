$ ->
  created = false
  $('#add-party').bind 'pageshow', ->
    if created
      # We need to bind to pageshow for the input to have the proper
      # width.
      return
    created = true

    $('[name=phone_number]', this).guest_search(
      field: 'phone'
    ).bind 'fill', (e, row) =>
      $('[name=name]', this).val row.name
      $('[name=notes]', this).val row.notes
      $('[name=alert_method]', this).val row.alert_method
      $('[name=seating_preference]', this).val row.seating_preference

      $('[name=party_size]', this).focus()
