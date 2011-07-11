$('#view-party').live 'pageshow', ->
  self = this

  # JQM doesn't support any sort of URL parameter passing
  key = $$('#queue-list').selected_key

  queue = $$('#queue-list').queue

  $('[data-key]', self).text ''

  queue.get key, (data) ->
    if not data
      alert 'Record not found'
      return

    $('[data-key=name]', self).text data.name
    $('[data-key=size]', self).text data.size

    $('[data-key=status]', self).text party.status data

    $('time.icon', self)
      .attr('datetime', data.add_time)
      .attr('data-target', data.quoted_wait)
      .time
        format: 'icon'

    do_delete = ->
      queue.remove data

      $(self).dialog 'close'

      $(this).unbind 'vclick', do_delete
      return false

    $('a[href=#delete-party]', self).bind 'vclick', do_delete


