$ ->
  $('#add-party').bind 'pagecreate', ->
    $('[name=phone_number]', this).guest_search(
      field: 'phone'
    ).bind 'fill', (e, row) =>
      $('[name=name]', this).val row.name
      $('[name=notes]', this).val row.notes
      $('[name=alert_method]', this).val row.alert_method
      $('[name=seating_preference]', this).val row.seating_preference

      $('[name=party_size]', this).focus()
