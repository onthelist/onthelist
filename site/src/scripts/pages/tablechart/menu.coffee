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

      spr = new $TC.MutableTable(tci, num, x, y, type)
      spr.draw()
      $(spr.canvas).trigger('select')

      window.spr = spr

      false

    _handlers = {}
    $('.tablechart-inner', this)
      .live('selectableselected', (e, ui) ->
        sel = ui.selected
        sprite = $$(sel).sprite

        # Size
        
        if _handlers.size?
          $size.unbind 'change', _handlers.size

        _handlers.size = ->
          sprite.seats = this.value
          do sprite.refresh

        $size.trigger('forceVal', [sprite.seats])

        $size.bind 'change', _handlers.size

        # Type
        if _handlers.types?
          $types.unbind 'change', _handlers.types

        _handlers.types = ->
          type = this.value

          sprite.change_shape(type)
          do sprite.refresh

        $types.filter("[value=#{sprite.shape}]").attr('checked', true)
        $types.filter(":not([value=#{sprite.shape}])").attr('checked', false)
        $types.checkboxradio('refresh')

        $types.bind 'change', _handlers.types

      )
      .live('selectableunselected', (e, ui) ->
        if _handlers.size?
          $size.unbind 'change', _handlers.size
      )
