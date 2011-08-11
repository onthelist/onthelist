$ ->
  $('#tablechart').bind 'pagecreate', ->
    chart = $TC.chart
    $tci = $(chart.cont)

    if not $tci.hasClass('ui-selectable')
      $tci.selectable()
      chart.selection = sel = $tci.data().selectable

      _enable = ->
        sel.options.disabled = false

      _disable = ->
        sel.options.disabled = true

      do _disable

      $TC.chart.live 'add', (e, sprite) ->
        $(sprite.canvas).bind 'select vclick', (e) ->
          do _enable
          sel._mouseStart e
          sel._mouseStop e
          do _disable
        
      $CTRL_KEYS.bind 'ctrldown', ->
        do _enable

      $CTRL_KEYS.bind 'ctrlup', ->
        do _disable
