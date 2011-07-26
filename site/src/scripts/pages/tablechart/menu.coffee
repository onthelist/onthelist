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

      obj = switch type
        when 'round' then $TC.RoundTable
        when 'rect' then $TC.RectTable
      
      spr = new obj(tci, num, x, y)
      spr.draw()
      $(spr.canvas).trigger('select')

      false

    _handlers = {}
    $('.tablechart-inner', this)
      .live('selectableselected', (e, ui) ->
        sel = ui.selected
        sprite = $$(sel).sprite

        $.log sprite

        # Size
        
        if _handlers.size?
          $size.unbind 'change', _handlers.size

        _handlers.size = ->
          sprite.seats = this.value
          do sprite.refresh

        $size.trigger('forceVal', [sprite.seats])

        $size.bind 'change', _handlers.size
      )
      .live('selectableunselected', (e, ui) ->
        if _handlers.size?
          $size.unbind 'change', _handlers.size
      )
