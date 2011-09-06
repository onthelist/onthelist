(function() {
  var _ref;
  if ((_ref = window.$UI) == null) {
    window.$UI = {};
  }
  window.$UI.get_page_space = function($page) {
    var $content, fh, height, hh, pb, pt, wh, width, _ref2, _ref3;
    $content = $page.children(".ui-content");
    hh = (_ref2 = $page.children(".ui-header").outerHeight()) != null ? _ref2 : 0;
    fh = (_ref3 = $page.children(".ui-footer").outerHeight()) != null ? _ref3 : 0;
    pt = parseFloat($content.css("padding-top"));
    pb = parseFloat($content.css("padding-bottom"));
    wh = window.innerHeight;
    height = wh - (hh + fh) - (pt + pb);
    width = window.innerWidth;
    return [width, height];
  };
  window.$UI.get_content_margin = function($page) {
    var $content, hh, pt, _ref2;
    if ($page == null) {
      $page = $('.ui-page-active');
    }
    $content = $page.children(".ui-content");
    hh = (_ref2 = $page.children(".ui-header").outerHeight()) != null ? _ref2 : 0;
    pt = parseFloat($content.css("padding-top"));
    return hh + pt;
  };
}).call(this);
