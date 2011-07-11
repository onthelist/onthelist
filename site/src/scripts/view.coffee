$('#view-party').live 'pageshow', ->
  self = this

  # JQM doesn't support any sort of URL parameter passing
  key = $$('#queue-list').selected_key

  queue = $$('#queue-list').queue

  queue.get key, (data) ->
    if not data
      alert 'Record not found'
      return

    $('[data-key=name]', self).text data.name
    $('[data-key=size]', self).text data.size

    $('time.icon', self)
      .attr('datetime', data.add_time)
      .attr('data-target', data.quoted_wait)
      .time
        format: 'icon'

    $('a[href=#delete-party]', self).click (e) ->
      queue.remove data

      $(self).dialog 'close'

      $(this).unbind 'click'

      return false
        


