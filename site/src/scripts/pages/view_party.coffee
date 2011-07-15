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
    $('[data-key=notes]', self).text data.notes

    $('[data-key=status]', self).text $F.party.status data

    $('time.icon', self)
      .attr('datetime', data.add_time)
      .attr('data-target', data.quoted_wait)
      .time
        format: 'icon'

    $('#text-actions', self)
      .change ->
        $.log $(this).val()

    fmt_phone = $F.phone data.phone
    $('#text-actions-menu li[tabindex=-1] a')
      .text("Call Guest at #{fmt_phone}")
      .attr("href", "tel:#{data.phone}")
      .bind 'vclick', ->
        # Rather than the select action, we want to actually
        # follow the URL
        document.location = $(this).attr('href')
        return false

    do_delete = ->
      queue.remove data

      $(self).dialog 'close'

      $(this).unbind 'vclick', do_delete
      return false

    $('a[href=#delete-party]', self).bind 'vclick', do_delete


