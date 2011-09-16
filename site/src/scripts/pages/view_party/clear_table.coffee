$ ->
  $('#view-party').bind 'pagecreate', ->
    $('[name=clear_table]', this).bind 'vclick', =>
      data = $$(this).data

      $(this).dialog 'close'

      $TRACK.track 'view-page-clear-table'

      $QUEUE.check_out data.key

      false
