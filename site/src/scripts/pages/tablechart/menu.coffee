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

      if sprites and sprites[0]
        x = sprites[0].x + ($TC.gaps?.x ? 40)
        y = sprites[0].y + ($TC.gaps?.y ? 40)

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
    
    sprites = null
    _clear_selection = ->
        do _remove_handlers

        $label.val ''

        $del.button 'disable'

        $menu.removeClass 'open'
        $menu.removeClass 'docked-right'
        $menu.addClass 'docked-left'

        sprites = null

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

    $('.tablechart-inner', this)
      .live('selectableselected', (e, ui) ->
        $canvases = $('.ui-selected', this)
        sprites = ($$(s).sprite for s in $canvases)

        do _remove_handlers

        if $(sprites[0].canvas).position().left < $menu.width()
          # The menu would cover the sprite
          $menu.removeClass 'docked-left'
          $menu.addClass 'docked-right'
       
        # We need to give the css time to add the right slide transition
        # (only necessary when the menu has been moved to the right side).
        setTimeout(-> $menu.addClass 'open', 0)

        # Size
        $size.trigger('forceVal', [sprites[0].seats])

        _add_handler 'size', $size, 'change', ->
          for sprite in sprites
            sprite.seats = this.value
            do sprite.update

        # Type
        $types.attr('checked', false)
        $types.filter("[value=#{sprites[0].__proto__.constructor.name}]").attr('checked', true)
        $types.checkboxradio('refresh')

        _add_handler 'types', $types, 'change', ->
          type = this.value

          for sprite, i in sprites
            sprites[i] = sprite = $TC.chart.change_type sprite, type
            $(sprite.canvas).addClass 'ui-selected'
            do sprite.update

        # Label
        $label.val(sprites[0].opts.label)

        _add_handler 'label', $label, 'keyup', ->
          for sprite in sprites
            sprite.opts.label = this.value
            do sprite.update

        # Rotation
        last_rotation = sprites[0].opts.rotation

        _add_handler 'rotation', $rots, 'vclick', (e) ->
          for sprite in sprites
            switch e.currentTarget.hash
              when '#left' then sprite.rotate(-90)
              when '#right' then sprite.rotate(90)

            do sprite.update

          last_rotation = sprites[0].opts.rotation

          false

        # Delete
        $del.button 'enable'
        _add_handler 'delete', $del, 'vclick', (e) ->
          for sprite in sprites
            $TC.chart.remove sprite

          false

      )
      .live('selectableunselected', _clear_selection)

    $TC.chart.bind 'remove', _clear_selection
