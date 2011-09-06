(function() {
  window.$TC.choose_table = function(opts) {
    var $tc, prev_loc, _selection;
    $tc = $('#tablechart');
    prev_loc = window.location.toString();
    window.location = '#tablechart';
    _selection = function(e, sel) {
      var sprite;
      sprite = $$(sel.selected).sprite;
      if (!(sprite.occupancy != null)) {
        return;
      }
      window.location = prev_loc;
      opts.success && opts.success(sprite);
      return $tc.unbind('scaled_selectableselected', _selection);
    };
    return $tc.bind('scaled_selectableselected', _selection);
  };
}).call(this);
