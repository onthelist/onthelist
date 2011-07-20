$ ->
  $('#tablechart').live 'pagecreate', ->
    tci = $('.tablechart-inner', this)[0]

    y = 100
    x = 0

    (new $TC.RoundTable(tci, 1, x += 100, y)).draw()
    (new $TC.RoundTable(tci, 2, x += 100, y)).draw()
    (new $TC.RoundTable(tci, 6, x += 100, y)).draw()
    (new $TC.RoundTable(tci, 12, x += 100, y)).draw()
    (new $TC.RoundTable(tci, 24, x += 100, y)).draw()

    y += 100
    x = 0

    (new $TC.RectTable(tci, 1, x += 100, y)).draw()
    (new $TC.RectTable(tci, 2, x += 100, y)).draw()
    (new $TC.RectTable(tci, 3, x += 100, y)).draw()
    (new $TC.RectTable(tci, 4, x += 100, y)).draw()
    (new $TC.RectTable(tci, 6, x += 100, y)).draw()
    (new $TC.RectTable(tci, 9, x += 100, y)).draw()
