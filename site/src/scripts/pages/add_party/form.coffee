$ ->
  $('#add-party').bind 'pagecreate', ->
    $('.ui-input-text', this).each (i, el) ->
      if el.value
        el.setAttribute('data-default', el.value)

  $('#add-party').bind 'pageshow', ->
    $('.ui-input-text', this).each (i, el) ->
      el.value = (el.getAttribute('data-default') ? '')

    $('.ui-input-text', this).first().focus()

  $('#add-party a[href=#add]').bind 'vclick', (e) ->
    dia = $ '#add-party'

    vals = {}
    $('#add-party input').each (i, elem) ->
      $elem = $ elem

      vals[$elem.attr('name')] = $elem.val()

    $D.queue.add(vals)

    dia.dialog 'close'

    false
