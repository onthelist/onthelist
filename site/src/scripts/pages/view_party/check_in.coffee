$ ->
  $('#view-party').bind 'pagecreate', ->
    $('[name=check_in]', this).bind 'vclick', (e) =>
      data = $$(this).data

      $(this).dialog 'close'

      $QUEUE.check_in data.id

      false
