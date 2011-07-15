$ ->
  $('#tablechart').live 'pagecreate', ->
    tci = $('.tablechart-inner', this)[0]

    y = 100
    x = 0

    (new RoundTable(tci, 1, x += 100, y)).draw()
    (new RoundTable(tci, 2, x += 100, y)).draw()
    (new RoundTable(tci, 6, x += 100, y)).draw()
    (new RoundTable(tci, 12, x += 100, y)).draw()
    (new RoundTable(tci, 24, x += 100, y)).draw()

    y += 100
    x = 0

    (new RectTable(tci, 1, x += 100, y)).draw()
    (new RectTable(tci, 2, x += 100, y)).draw()
    (new RectTable(tci, 3, x += 100, y)).draw()
    (new RectTable(tci, 4, x += 100, y)).draw()
    (new RectTable(tci, 6, x += 100, y)).draw()
    (new RectTable(tci, 9, x += 100, y)).draw()
