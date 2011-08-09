window.$TC ?= {}
$TC.scroller = null

BASE_HEIGHT = 720.0
BASE_WIDTH = 1280.0
MIN_SCALE = 0.5

$ ->
  $page = $('#tablechart')
  $tc = $('.tablechart', $page)
  $tci = $('.tablechart-inner', $page)
  $contain = $('.tc-container', $page)
  
  $TC.chart = new $TC.Chart($tci[0])

  $page.bind 'pageshow', ->
    $this = $ this

    do $TC.chart.draw
    
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
      # tc-container
      #   - set to size of visible space, overflow hidden [clipping layer]
      #   tablechart
      #     - set to size of scaled chart, the 'canvas' which is scrolled
      #     tablechart-inner
      #       - set to 1280 x 720
      
      [width, height] = $UI.get_page_space $this

      # All the chart coords are based on 1280 x 720
      x_fact = width / BASE_WIDTH
      y_fact = height / BASE_HEIGHT

      max_fact = Math.max(x_fact, y_fact)
      min_fact = Math.min(x_fact, y_fact)

      if min_fact > MIN_SCALE
        fact = min_fact
        center = true
      else
        fact = max_fact
        center = false

      $tci.css('left', 0).css('top', 0)

      if center
        # If the screen is large enough to show the chart at, at least, 50%
        # scale, we scale it to the larger dimention and center the other.
        if min_fact == y_fact
          $tci.css('left', (width - fact * BASE_WIDTH) / 2.0 + 'px')
        else
          $tci.css('top', (height - fact * BASE_HEIGHT) / 2.0 + 'px')

      
      # The scaling will shrink the chart, but not the space allocated
      # for it, the content area forms a clip to prevent scrolling.
      $contain.height height + 'px'

      $tc.height BASE_HEIGHT + 'px'
      $tc.width BASE_WIDTH + 'px'
      
      if $TC.scroller
        setTimeout(->
          # iScroll docs recommend using setTimeout 
          $TC.scroller.refresh()
          $TC.scroller.zoom(0, 0, fact, 0)
        , 0)

      return fact

    fact = do update_size
    
    $win = $(window)
    $win.bind 'resize', update_size

    $win.bind 'beforepageshow', ->
      $win.unbind 'resize', update_size

    if not $TC.scroller
      opts =
        lockDirection: false
        hScrollbar: true
        zoom: true
        zoomMax: 6
        zoomMin: .1

      $TC.scroller = new iScroll $contain[0], opts

      do update_size
