$('#view-party').live 'pageshow', ->
  self = this

  # JQM doesn't support any sort of URL parameter passing
  key = $$('#queue-list').selected_key

  $('[data-key]', self).text ''

  $D.parties.get key, (data) ->
    if not data
      alert 'Record not found'
      return

    $$(self).data = data

    $('[data-key=name]', self).text data.name
    $('[data-key=size]', self).text data.size
    $('[data-key=notes]', self).text data.notes

    $('[data-key=status]', self).text $F.party.status data

    $('time.icon', self)
      .attr('datetime', data.times.add)
      .attr('data-target', data.quoted_wait)
      .time
        format: 'icon'

    # Alert Button
    $alert_lbl = $('[name=alert_party] .ui-btn-text', self)
    _update_button = =>
      $alert_lbl.text $F.party.alert_btn data

    data.bind 'status:change', _update_button
    $(self).bind 'pagehide', ->
      data.unbind 'status:change', _update_button

    do _update_button

    # Clear Button
    if data.status.has 'seated'
      do $('[name=check_in]', self).hide
      do $('[name=clear_table]', self).show
    else
      do $('[name=check_in]', self).show
      do $('[name=clear_table]', self).hide

    # Call Action
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
      $D.parties.remove data

      $(self).dialog 'close'

      $(this).unbind 'vclick', do_delete
      return false

    $('a[href=#delete-party]', self).bind 'vclick', do_delete


