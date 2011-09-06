$ ->
  $('#view-party').bind 'pagecreate', ->
    $('[name=clear_table]', this).bind 'vclick', =>
      data = $$(this).data

      $(this).dialog 'close'

      $QUEUE.check_out data.key

      false
