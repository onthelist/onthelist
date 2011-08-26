$ ->
  $('#view-party').bind 'pagecreate', ->
    page = this

    $('[name=alert_party]', this).bind 'vclick', (e) ->
      data = $$(page).data

      $IO.alert data

      false
