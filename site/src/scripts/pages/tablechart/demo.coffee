$ ->
  $('#tablechart').live 'pagecreate', ->
    tci = $('.tablechart-inner', this)[0]

    for [y, shape] in [[100, 'round'], [200, 'rect']]
      x = 0
      for size in [1, 2, 6, 12, 24]
        x += 100

        opts =
          parent: tci
          seats: size
          x: x
          y: y
          shape: shape
          label: l=Math.floor(Math.random() * 100)
          rotation: l

        (new $TC.MutableTable(opts)).draw()
