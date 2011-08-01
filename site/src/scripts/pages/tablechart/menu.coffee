$ ->
  $('#tablechart').bind 'pagecreate', ->
    $menu = $('.editor', this)
    $form = $('form', $menu)
    $size = $('[data-key=size]', $form)
    $types = $('[name=type]', $form)
    $label = $('[name=label]', $form)
    $rots = $('#table-rotation a', $form)

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

    _add_handler = (name, $elems, evt='change', func) ->
      _handlers[name] =
        func: func
        $elems: $elems
        evt: evt

      $elems.bind evt, _handlers[name].func

    _remove_handlers = ->
      for own name, obj of _handlers
        obj.$elems.unbind obj.evt, obj.func

    $('.tablechart-inner', this)
      .live('selectableselected', (e, ui) ->
        sel = ui.selected
        sprite = $$(sel).sprite

        do _remove_handlers

        # Size
        $size.trigger('forceVal', [sprite.seats])

        _add_handler 'size', $size, 'change', ->
          sprite.seats = this.value
          do sprite.refresh

        # Type
        $types.filter("[value=#{sprite.shape}]").attr('checked', true)
        $types.filter(":not([value=#{sprite.shape}])").attr('checked', false)
        $types.checkboxradio('refresh')

        _add_handler 'types', $types, 'change', ->
          type = this.value

          sprite.change_shape(type)
          do sprite.refresh

        # Label
        $label.val(sprite.opts.label)

        _add_handler 'label', $label, 'change', ->
          sprite.opts.label = this.value
          do sprite.refresh

        # Rotation
        _add_handler 'rotation', $rots, 'vclick', (e) ->
          switch e.currentTarget.hash
            when '#left' then sprite.rotate(-90)
            when '#right' then sprite.rotate(90)

          do sprite.refresh

          false

      )
      .live('selectableunselected', (e, ui) ->
        do _remove_handlers
      )
