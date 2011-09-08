$ ->
  $('#tablechart').bind 'pagecreate', ->
    chart = $TC.chart
    $tci = $(chart.cont)

    if not $tci.hasClass('ui-selectable')
      $tci.scaled_selectable()
      
      chart.selection = sel = $tci.data().scaled_selectable

      _enable = ->
        sel.options.disabled = false

      _disable = ->
        sel.options.disabled = true

      do _disable

      $TC.chart.live 'add', (e, sprite) ->
        $.when( sprite.canvas_ready() ).then ->

          $(sprite.canvas).bind 'select vmousedown', (e) ->
            if $(this).hasClass 'ui-selected'
              return

            do _enable
            sel._mouseStart e
            sel._mouseStop e
            do _disable
        
      $CTRL_KEYS.bind 'ctrldown', ->
        do _enable

      $CTRL_KEYS.bind 'ctrlup', ->
        do _disable

      $tci.bind 'vmousedown', (e) ->
        # vclick/click are blocked by the JUI widgets used for selection / dragging
        if e.target == $tci[0]
          $tci.find('.ui-selected').removeClass('ui-selected')
          $tci.trigger('scaled_selectableunselected')

      $tci.bind 'scaled_selectableselected', (e, sel) ->
        if not $TC.chart.editable
          table = $$(sel.selected).sprite

          occupant = table.occupancy?.occupant
          if not occupant?
            return
  
          $QUEUE.show_view_page occupant.key
