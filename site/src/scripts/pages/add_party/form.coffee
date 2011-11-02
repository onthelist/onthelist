$ ->
  $('#add-party').bind 'pagecreate', ->
    $('.ui-input-text', this).each (i, el) ->
      if el.value
        el.setAttribute('data-default', el.value)

  $('#add-party').bind 'pageshow', ->
    page = this
    $pages = $('.ui-page').not(this)

    # When another page is shown (this page has been hidden), clear
    # the fields.  Doing it on close, rather than open, prevents
    # conflicts with the editing data being loaded.
    _clear = ->
      $('.ui-input-text', page).each (i, el) ->
        el.value = (el.getAttribute('data-default') ? '')

      $pages.unbind 'pageshow', _clear
    $pages.bind 'pageshow', _clear

    $('#party-called-ahead').val('false')
    $('#party-called-ahead').slider('refresh')

    $('.ui-slider-input').slider('refresh')

    $('.ui-input-text', this).first().focus()

  $('#add-party form.content').bind 'submit', (e) ->
    do e.stopPropagation
    do e.preventDefault

    dia = $ '#add-party'

    vals = $$(dia).data ? {}
    $('#add-party').find('input:not([type=submit]), select').each (i, elem) ->
      $elem = $ elem

      if $elem.attr('type') == 'submit'
        return

      if $elem.filter('[type=checkbox], [type=radio]').length
        if $elem.attr('checked') == 'checked'
          vals[$elem.attr('name')] = $elem.val()

      else
        vals[$elem.attr('name')] = $elem.val()

    if not vals.name or vals.name == ''
      return false

    key = $$('#queue-list').selected_key
    if key
      vals.key = key
    else
      vals.key = undefined

    vals.alert_method ?= 'sms'
    $.log vals

    vals.status ?= ['waiting']
    if vals.called_ahead and vals.called_ahead != 'false'
      vals.status.push 'called_ahead'

    dia.dialog 'close'

    $TRACK.track('add-party', vals)
    $D.parties.save(vals)

    false
