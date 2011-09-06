(function() {
  var get_fixed_margin, _ref;
  get_fixed_margin = function() {
    var $cont, offset, scaled_margin;
    $cont = $($TC.chart.cont);
    offset = $cont.offset();
    scaled_margin = $cont.position();
    return {
      top: offset.top - scaled_margin.top,
      left: offset.left - scaled_margin.left
    };
  };
  if ((_ref = window.$TC) == null) {
    window.$TC = {};
  }
  $TC.scale_page_coords = function(x, y) {
    var fixed_margin;
    fixed_margin = get_fixed_margin();
    y -= fixed_margin.top;
    x -= fixed_margin.left;
    x *= 1 / $TC.scroller.scale;
    y *= 1 / $TC.scroller.scale;
    y += fixed_margin.top;
    x += fixed_margin.left;
    x += -$TC.scroller.x;
    y += -$TC.scroller.y;
    return [x, y];
  };
  $TC.scale_rel_coords = function(x, y) {
    var fixed_margin;
    fixed_margin = get_fixed_margin();
    y -= fixed_margin.top;
    x -= fixed_margin.left;
    x *= $TC.scroller.scale;
    y *= $TC.scroller.scale;
    y += fixed_margin.top;
    x += fixed_margin.left;
    x -= -$TC.scroller.x;
    y -= -$TC.scroller.y;
    return [x, y];
  };
  $.widget("ui.scaled_selectable", $.ui.selectable, {
    options: $.ui.selectable.prototype.options,
    _mouseStart: function(evt) {
      var _ref2;
      _ref2 = $TC.scale_page_coords(evt.pageX, evt.pageY), evt.pageX = _ref2[0], evt.pageY = _ref2[1];
      return $.ui.selectable.prototype._mouseStart.call(this, evt);
    },
    _mouseDrag: function(evt) {
      var ret, x1, x2, y1, y2, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8;
      _ref2 = $TC.scale_page_coords(evt.pageX, evt.pageY), evt.pageX = _ref2[0], evt.pageY = _ref2[1];
      _ref3 = this.opos, x1 = _ref3[0], y1 = _ref3[1];
      _ref4 = [evt.pageX, evt.pageY], x2 = _ref4[0], y2 = _ref4[1];
      ret = $.ui.selectable.prototype._mouseDrag.call(this, evt);
      if (x1 > x2) {
        _ref5 = [x2, x1], x1 = _ref5[0], x2 = _ref5[1];
      }
      if (y1 > y2) {
        _ref6 = [y2, y1], y1 = _ref6[0], y2 = _ref6[1];
      }
      _ref7 = $TC.scale_rel_coords(x1, y1), x1 = _ref7[0], y1 = _ref7[1];
      _ref8 = $TC.scale_rel_coords(x2, y2), x2 = _ref8[0], y2 = _ref8[1];
      this.helper.css({
        left: x1,
        top: y1,
        width: x2 - x1,
        height: y2 - y1
      });
      return ret;
    }
  });
}).call(this);
