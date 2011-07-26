$ ->
  $('#tablechart').bind 'pageshow', ->
    $tci = $('.tablechart-inner', this)

    $tci.selectable()

    $('canvas', $tci).live 'select vclick', (e) ->
      sel = $tci.data().selectable

      sel._mouseStart e
      sel._mouseStop e

