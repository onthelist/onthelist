$ ->
  $('#tablechart').live 'pagecreate', ->
    tci = $('.tablechart-inner', this)[0]

    y = 100
    x = 0

    (new $TC.MutableTable(tci, 1, x += 100, y, 'round')).draw()
    (new $TC.MutableTable(tci, 2, x += 100, y, 'round')).draw()
    (new $TC.MutableTable(tci, 6, x += 100, y, 'round')).draw()
    (new $TC.MutableTable(tci, 12, x += 100, y, 'round')).draw()
    (new $TC.MutableTable(tci, 24, x += 100, y, 'round')).draw()

    y += 100
    x = 0

    (new $TC.MutableTable(tci, 1, x += 100, y, 'rect')).draw()
    (new $TC.MutableTable(tci, 2, x += 100, y, 'rect')).draw()
    (new $TC.MutableTable(tci, 3, x += 100, y, 'rect')).draw()
    (new $TC.MutableTable(tci, 4, x += 100, y, 'rect')).draw()
    (new $TC.MutableTable(tci, 6, x += 100, y, 'rect')).draw()
    (new $TC.MutableTable(tci, 9, x += 100, y, 'rect')).draw()
