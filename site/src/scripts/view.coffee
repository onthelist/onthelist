$('#view-party').live 'pageshow', ->
  self = this

  # JQM doesn't support any sort of URL parameter passing
  key = $$('#queue-list').selected_key

  queue = $$('#queue-list').queue

  queue.get key, (data) ->
    $('[data-key=name]', self).text data.name
    $('[data-key=size]', self).text data.size

    $('a[href=#delete-party]', self).click (e) ->
      queue.remove data

      $(self).dialog 'close'

      $(this).unbind 'click'

      return false
        


