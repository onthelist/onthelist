$ ->
  $('#tablechart').bind 'pageshow', ->
    $tci = $('.tablechart-inner', this)

    if not $tci.hasClass('ui-selectable')
      $tci.selectable()

      $TC.chart.bind 'add', (e, sprite) ->
        $(sprite.canvas).live 'select vclick', (e) ->
          sel = $tci.data().selectable

          sel._mouseStart e
          sel._mouseStop e
