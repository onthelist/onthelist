$ ->
  $('#view-party').bind 'pagecreate', ->
    $('[name=check_in]', this).bind 'vclick', (e) =>
      data = $$(this).data

      $(this).dialog 'close'

      $TRACK.track 'view-page-check-in'

      $QUEUE.check_in data.key

      false
