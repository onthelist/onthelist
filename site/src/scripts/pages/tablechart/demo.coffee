$ ->
  $('#tablechart').live 'pagecreate', ->
    $.when( $D.charts.init() ).then ->
      $D.charts.ds.all (rows) ->
        if not rows or rows.length == 0
          for [y, shape] in [[100, 'round'], [200, 'rect']]
            x = 0
            for size in [1, 2, 6, 12, 24]
              x += 100

              opts =
                seats: size
                x: x
                y: y
                shape: shape
                label: l=Math.floor(Math.random() * 100)

              $TC.chart.add(new $TC.MutableTable(opts))

          do $TC.chart.save
