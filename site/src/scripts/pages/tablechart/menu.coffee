$ ->
  $('#tablechart').bind 'pagecreate', ->
    $menu = $('.editor', this)
    $form = $('form', $menu)
    $size = $('[data-key=size]', $form)
    $types = $('[name=table_type]', $form)

    $add = $('a[href=#add-table]', $menu)

    $add.bind 'vclick', ->
      num = parseInt $size.val()
      x = 500
      y = 250
      tci = $('.tablechart-inner')[0]

      type = $types.filter(':checked').attr('value') ? 'round'

      opts =
        parent: tci
        seats: num
        x: x
        y: y
        shape: type
      spr = new $TC.MutableTable(opts)
      spr.draw()
      $(spr.canvas).trigger('select')

      window.spr = spr

      false

    _handlers = {}
    _remove_handler = (name, $elems) ->
      if _handlers[name]?
        $elems.unbind 'change', _handlers[name]

    _add_handler = (name, $elems, func) ->
      _handlers[name] = func

      $elems.bind 'change', _handlers[name]

    $('.tablechart-inner', this)
      .live('selectableselected', (e, ui) ->
        sel = ui.selected
        sprite = $$(sel).sprite

        # Size
        _remove_handler 'size', $size

        $size.trigger('forceVal', [sprite.seats])

        _add_handler 'size', $size, ->
          sprite.seats = this.value
          do sprite.refresh

        # Type
        _remove_handler 'types', $types

        $types.filter("[value=#{sprite.shape}]").attr('checked', true)
        $types.filter(":not([value=#{sprite.shape}])").attr('checked', false)
        $types.checkboxradio('refresh')

        _add_handler 'types', $types, ->
          type = this.value

          sprite.change_shape(type)
          do sprite.refresh

      )
      .live('selectableunselected', (e, ui) ->
        if _handlers.size?
          $size.unbind 'change', _handlers.size
      )
