scroller = null

BASE_HEIGHT = 720.0
BASE_WIDTH = 1280.0

$('#tablechart').live 'pageshow', ->
  $this = $ this
  $tc = $('.tablechart', this)
  $tci = $('.tablechart-inner', this)
  $content = $('.ui-content', this)

  update_size = =>
    # The JQM css sets page min-height based on the landscape and portrait 
    # classes.
    # 
    # Even if we override the min-height on the page, it still follows the
    # overrode properties, so we [unfortunatly] have to get rid of those
    # classes on the page to completly remove the min-height on this page.
    $('html').removeClass 'landscape portrait'

    # ELEMENTS:
    #
    # content
    #   - set to size of visible space, overflow hidden [clipping layer]
    #   tablechart
    #     - set to size of scaled chart, the 'canvas' which is scrolled
    #     tablechart-inner
    #       - set to 1280 x 720, but scaled with css to set the 'default'
    #         zoom based on the size of the screen.
    
    [width, height] = $UI.get_page_space $this

    # All the chart coords are based on 1280 x 720
    x_fact = width / BASE_WIDTH
    y_fact = height / BASE_HEIGHT

    max_fact = Math.max(x_fact, y_fact)
    min_fact = Math.min(x_fact, y_fact)

    if min_fact > 0.5
      fact = min_fact
      center = true
    else
      fact = max_fact
      center = false

    # JQ won't set the experimental props using '.css'.
    $tci.attr('style', "-webkit-transform:scale(#{fact}, #{fact});-moz-transform:scale(#{fact}, #{fact});")

    if center
      # If the screen is large enough to show the chart at, at least, 50%
      # scale, we scale it to the larger dimention and center the other.
      if min_fact == y_fact
        $tci.css('left', (width - fact * BASE_WIDTH) / 2.0 + 'px')
      else
        $tci.css('top', (height - fact * BASE_HEIGHT) / 2.0 + 'px')
    
    # The scaling will shrink the chart, but not the space allocated
    # for it, the content area forms a clip to prevent scrolling.
    $content.height height + 'px'

    $tc.height (BASE_HEIGHT * fact) + 'px'
    $tc.width (BASE_WIDTH * fact) + 'px'

  do update_size

  $win = $(window)
  $win.bind 'resize', update_size

  $win.bind 'beforepageshow', ->
    $win.unbind 'resize', update_size

  opts =
    lockDirection: false
    hScrollbar: true
    zoom: true
    zoomMax: 6

  scroller = new iScroll $content[0], opts
