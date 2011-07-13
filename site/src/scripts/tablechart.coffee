get_page_space = ($page) ->
  $content = $page.children(".ui-content")
  hh = $page.children(".ui-header").outerHeight(); hh = hh ? hh : 0
  fh = $page.children(".ui-footer").outerHeight(); fh = fh ? fh : 0
  pt = parseFloat($content.css("padding-top"))
  pb = parseFloat($content.css("padding-bottom"))
  wh = window.innerHeight

  height = wh - (hh + fh) - (pt + pb)

  width = window.innerWidth

  return [width, height]

$ ->
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
      
      [width, height] = get_page_space $this

      # All the chart coords are based on 1280 x 720
      x_fact = width / 1280.0
      y_fact = height / 720.0

#      x_fact = Math.max(x_fact, 0.5)
#      y_fact = Math.max(y_fact, 0.5)

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
          $tci.css('left', (width - fact * 1280) / 2.0 + 'px')
        else
          $tci.css('top', (height - fact * 720) / 2.0 + 'px')

      # The scaling will shrink the chart, but not the space allocated
      # for it, the content area forms a clip to prevent scrolling.
      $content.height height + 'px'

      $tc.height (720 * fact) + 'px'
      $tc.width (1280 * fact) + 'px'

    do update_size

    $win = $(window)
    $win.bind 'resize', update_size

    $win.bind 'beforepageshow', ->
      $win.unbind 'resize', update_size

    #$content.scrollview opts
    $(document).bind 'touchmove', (e) ->
      do e.preventDefault
    
    opts =
      lockDirection: false
      hScrollbar: true
      zoom: true

    scroll = new iScroll $content[0], opts

