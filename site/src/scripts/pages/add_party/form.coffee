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

    $('.ui-input-text', this).first().focus()

  $('#add-party a[href=#add]').bind 'vclick', (e) ->
    dia = $ '#add-party'

    vals = $$(dia).data ? {}
    $('#add-party input').each (i, elem) ->
      $elem = $ elem

      if $elem.filter('[type=checkbox], [type=radio]').length
        if $elem.attr('checked') == 'checked'
          vals[$elem.attr('name')] = $elem.val()

      else
        vals[$elem.attr('name')] = $elem.val()

    key = $$('#queue-list').selected_key
    if key
      vals.key = key

    vals.status ?= 'waiting'

    $D.parties.save(vals)

    dia.dialog 'close'

    false
