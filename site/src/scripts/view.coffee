$('#view-party').live 'pageshow', ->
  # JQM doesn't support any sort of URL parameter passing
  key = $$('#queue-list').selected_key

  queue = $$('#queue-list').queue.ds

  queue.get key, (data) ->
    console.log data
