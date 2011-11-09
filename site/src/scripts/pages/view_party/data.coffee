$('#view-party').live 'pageshow', ->
  self = this

  key = do $PAGE.get_arg

  $('#add-party-link', self).attr 'href', "#add-party?#{key}"

  $('[data-key]', self).text ''

  $D.parties.get key, (data) ->
    if not data
      $.log 'Record not found'
      document.location = '#'
      return

    $$(self).data = data

    $('[data-key=name]', self).text data.name
    $('[data-key=size]', self).text data.size ? '-'
    $('[data-key=notes]', self).text data.notes

    $('[data-key=status]', self).text $F.party.status data

    if data.times?.add? and data.quoted_wait?
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
    if data.phone?
      fmt_phone = $F.phone data.phone
      $('#text-actions-menu li[tabindex=-1] a')
        .text("Call Guest at #{fmt_phone}")
        .attr("href", "tel:#{data.phone}")
        .bind 'vclick', ->
          # Rather than the select action, we want to actually
          # follow the URL
          document.location = $(this).attr('href')
          return false

    do_delete = (e) ->
      do e.stopPropagation
      do e.preventDefault

      $D.parties.remove data

      $(self).dialog 'close'

      false

    $('[name=delete_party]', self).unbind('vclick').bind 'vclick', do_delete


