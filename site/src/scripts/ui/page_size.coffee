window.$UI ?= {}
window.$UI.get_page_space = ($page) ->
  $content = $page.children(".ui-content")
  hh = $page.children(".ui-header").outerHeight(); hh = hh ? hh : 0
  fh = $page.children(".ui-footer").outerHeight(); fh = fh ? fh : 0
  pt = parseFloat($content.css("padding-top"))
  pb = parseFloat($content.css("padding-bottom"))
  wh = window.innerHeight

  height = wh - (hh + fh) - (pt + pb)

  width = window.innerWidth

  return [width, height]

