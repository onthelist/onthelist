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

      $TC.chart.live 'add', (e, sprite) ->
        if sprite.selectable == false
          return

        $.when( sprite.canvas_ready() ).then ->
          $cvs = $ sprite.canvas

          is_drag = false
          drag_TO = null
          $cvs.bind 'vmousedown', ->
            if drag_TO?
              clearTimeout drag_TO

            is_drag = false
            drag_TO = setTimeout(->
              is_drag = true
            , 150)

          $cvs.bind 'select vmouseup', (e) ->
            if is_drag and $cvs.hasClass 'ui-selected'
              # It was a drag, so we want the selection to still include
              # the other elements dragged.  If the downtime is less than
              # 150ms, we consider it a click, which will reset the sel
              # to just the clicked element.
              return

            sel._mouseStart e, true
            sel._mouseStop e
        
      $tci.bind 'vmousedown', (e) ->
        # vclick/click are blocked by the JUI widgets used for selection / dragging
        if e.target == $tci[0]
          $tci.find('.ui-selected').removeClass('ui-selected')
          $tci.trigger('scaled_selectableunselected')

        true

      $tci.bind 'scaled_selectableselected', (e, sel) ->
        if not $TC.chart.editable
          table = $$(sel.selected).sprite

          occupant = table.occupancy?.occupant
          if not occupant?
            return
  
          $QUEUE.show_view_page occupant.key
