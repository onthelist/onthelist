$ ->
  $('#tablechart').bind 'pagecreate', ->
    $menu = $('.editor', this)
    $form = $('form', $menu)
    $size = $('[data-key=size]', $form)
    $types = $('[name=type]', $form)
    $label = $('[name=label]', $form)
    $rots = $('#table-rotation a', $form)
    $section = $('#table-section', $form)

    $del = $('[name=del-table]', $menu)
    $del.button 'disable'

    last_rotation = 0

    _build_section_list = ->
      $section.html ''
      $section.append $ '<option value="false">No Section</option>'
      $section.append $ "<option value='add'>New Section</option>"
      $section.append $ '<option value="false">----------</option>'
      
      for own key, section of $TC.chart.sections
        $section.append $ "<option value='#{key}'>#{section.opts.label}</option>"

      $section.selectmenu()

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
      if not isNaN(parseInt(lbl, 10))
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
  
        if sprites?
          for sprite in sprites
            sprite.pop_style 'selected'
        
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
      .bind('scaled_selectableselected', (e, ui) ->
        init_sel = not sprites?

        $canvases = $('.ui-selected', this)
        sprites = ($$(s).sprite for s in $canvases)

        for sprite in sprites
          sprite.push_style 'selected'

        do _remove_handlers

        if $(sprites[0].canvas).position().left * $TC.scroller.scale < $menu.width()
          # The menu would cover the sprite
          $menu.removeClass 'docked-left'
          $menu.addClass 'docked-right'
       
        # We need to give the css time to add the right slide transition
        # (only necessary when the menu has been moved to the right side).
        setTimeout(-> $menu.addClass 'open', 0)

        # Size
        if init_sel
          $size.trigger('forceVal', [sprites[0].seats])

        _add_handler 'size', $size, 'change', ->
          for sprite in sprites
            sprite.seats = this.value
            do sprite.update

        # Type
        if init_sel
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
        if init_sel
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

        # Sections
        do _build_section_list

        section = $TC.chart.get_section sprites[0]
        if section?
          $section.val section.opts.key
        else
          $section.val false
        $section.selectmenu 'refresh'

        _add_handler 'change', $section, 'change', (e) ->
          val = $section.val()

          sec = null
          if val == 'add'
            col = do $TC.chart.next_section_color
            name = col.capitalize true

            sec = new $TC.Section
              label: name
              color: col

            $TC.chart.add sec

            do _build_section_list

            $section.val sec.opts.key
            $section.selectmenu 'refresh'

          else if val
            sec = $TC.chart.get_sprite val

          for sprite in sprites
            old_sec = $TC.chart.get_section sprite
            if old_sec?
              old_sec.remove_table sprite

            if sec?
              sec.add_table sprite
          
          do $TC.chart.save

        # Delete
        $del.button 'enable'
        _add_handler 'delete', $del, 'vclick', (e) ->
          if sprites?
            # sprites has to be cloned, as it will be cleared
            # when the first sprite is removed.
            for sprite in sprites.clone()
              $TC.chart.remove sprite

          false

      )
      .bind('scaled_selectableunselected', _clear_selection)

    $TC.chart.bind 'remove', _clear_selection

    if not $TC.chart.editable
      $menu.hide()

    $TC.chart.bind 'locked', ->
      $menu.hide()
    $TC.chart.bind 'unlocked', ->
      $menu.show()

