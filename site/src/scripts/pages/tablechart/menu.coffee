$ ->
  $('#tablechart').bind 'pagecreate', ->
    $menu = $('.editor', this)
    $form = $('form', $menu)
    $size = $('[data-key=size]', $form)
    $types = $('[name=type]', $form)
    $label = $('[name=label]', $form)
    $rots = $('#table-rotation a', $form)

    $del = $('[name=del-table]', $menu)
    $del.button 'disable'

    last_rotation = 0

    $menu.bind 'vclick', (e) ->
      if e.target.tagName not in ['A', 'SPAN', 'BUTTON', 'INPUT']
        $menu.toggleClass 'manual-open'

    $add = $('a[href=#add-table]', $menu)
    $add.bind 'vclick', ->
      num = parseInt $size.val()
      x = 500
      y = 250
      tci = $('.tablechart-inner')[0]

      type = $types.filter(':checked').attr('value') ? 'RoundTable'

      lbl = $label.val()
      if parseInt(lbl, 10) != NaN
        lbl = (parseInt(lbl, 10) + 1)

      if sprite
        x = sprite.x + ($TC.gaps?.x ? 40)
        y = sprite.y + ($TC.gaps?.y ? 40)

      opts =
        seats: num
        x: x
        y: y
        label: lbl
        rotation: last_rotation

      spr = $TC.chart.add opts, type
      do $TC.chart.save
      do $TC.chart.draw

      $(spr.canvas).trigger('select')

      window.spr = spr

      do $label.focus
      $label.caret 0, 10

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
    
      _add_handler 'rotation', $rots, 'vclick', (e) ->
        # Block default action
        false

    do _remove_handlers

    sprite = null
    $('.tablechart-inner', this)
      .live('selectableselected', (e, ui) ->
        sel = ui.selected
        sprite = $$(sel).sprite

        do _remove_handlers

        $menu.addClass 'open'

        # Size
        $size.trigger('forceVal', [sprite.seats])

        _add_handler 'size', $size, 'change', ->
          sprite.seats = this.value
          do sprite.update

        # Type
        $types.attr('checked', false)
        $types.filter("[value=#{sprite.__proto__.constructor.name}]").attr('checked', true)
        $types.checkboxradio('refresh')

        _add_handler 'types', $types, 'change', ->
          type = this.value

          sprite = $TC.chart.change_type sprite, type
          $(sprite.canvas).trigger('select')
          do sprite.update

        # Label
        $label.val(sprite.opts.label)

        _add_handler 'label', $label, 'keyup', ->
          sprite.opts.label = this.value
          do sprite.update

        # Rotation
        last_rotation = sprite.opts.rotation

        _add_handler 'rotation', $rots, 'vclick', (e) ->
          switch e.currentTarget.hash
            when '#left' then sprite.rotate(-90)
            when '#right' then sprite.rotate(90)

          do sprite.update

          last_rotation = sprite.opts.rotation

          false

        # Delete
        $del.button 'enable'
        _add_handler 'delete', $del, 'vclick', (e) ->
          $TC.chart.remove sprite

          false

      )
      .live('selectableunselected spriteRemoved', (e, ui) ->
        do _remove_handlers

        $label.val ''

        $del.button 'disable'

        $menu.removeClass 'open'

        sprite = null
      )
