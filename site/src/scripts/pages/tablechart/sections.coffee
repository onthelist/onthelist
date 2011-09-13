$ ->
  $TC.chart.live 'add', (e, sprite) ->
    if not sprite.is_section
      sprite.bind 'move', ->
        do $TC.chart.refresh_sections

