$ ->
  $('#view-party').bind 'pagecreate', ->
    page = this

    $('[name=alert_party]', this).bind 'vclick', (e) ->
      data = $$(page).data

      $TRACK.track 'view-page-alert'

      $IO.alert data

      false
