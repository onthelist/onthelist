$ ->
    _handle_click = (e) ->
      if e.clientY > 45
        return

      if e.originalEvent?.target?.tagName in ["A", "BUTTON", "INPUT", "SPAN"]
        return

      side = null
      if e.clientX < 80
        side = 'left'
      else if e.clientX > (window.innerWidth - 80)
        side = 'right'

      if not side
        return

      $link = $(".ui-page-active .ui-header .ui-btn-#{side}:visible")

      $link.trigger('vclick', [e])

    $(document).bind 'vclick', _handle_click
