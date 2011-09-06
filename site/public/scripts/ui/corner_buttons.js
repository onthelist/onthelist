(function() {
  $(function() {
    var _handle_click;
    _handle_click = function(e) {
      var $link, side, _ref, _ref2, _ref3;
      if (e.clientY > 45) {
        return;
      }
      if ((_ref = (_ref2 = e.originalEvent) != null ? (_ref3 = _ref2.target) != null ? _ref3.tagName : void 0 : void 0) === "A" || _ref === "BUTTON" || _ref === "INPUT" || _ref === "SPAN") {
        return;
      }
      side = null;
      if (e.clientX < 80) {
        side = 'left';
      } else if (e.clientX > (window.innerWidth - 80)) {
        side = 'right';
      }
      if (!side) {
        return;
      }
      $link = $(".ui-page-active .ui-header .ui-btn-" + side + ":visible");
      return $link.trigger('vclick', [e]);
    };
    return $(document).bind('vclick', _handle_click);
  });
}).call(this);
