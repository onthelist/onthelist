$ ->
  $('#view-party').bind 'pagecreate', ->
    page = this

    $('[name=alert_party]', this).bind 'vclick', (e) ->
      data = $$(page).data
      $M.send(data.phone, 'Your table is ready! Please visit the host stand to be seated.')

      false
