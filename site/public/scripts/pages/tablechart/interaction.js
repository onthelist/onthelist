(function() {
  $(function() {
    return $('#tablechart').bind('pagecreate', function() {
      var $tci, chart, sel, _disable, _enable;
      chart = $TC.chart;
      $tci = $(chart.cont);
      if (!$tci.hasClass('ui-selectable')) {
        $tci.scaled_selectable();
        chart.selection = sel = $tci.data().scaled_selectable;
        _enable = function() {
          return sel.options.disabled = false;
        };
        _disable = function() {
          return sel.options.disabled = true;
        };
        _disable();
        $TC.chart.live('add', function(e, sprite) {
          return $.when(sprite.canvas_ready()).then(function() {
            return $(sprite.canvas).bind('select vmousedown', function(e) {
              _enable();
              sel._mouseStart(e);
              sel._mouseStop(e);
              return _disable();
            });
          });
        });
        $CTRL_KEYS.bind('ctrldown', function() {
          return _enable();
        });
        $CTRL_KEYS.bind('ctrlup', function() {
          return _disable();
        });
        $tci.bind('vmousedown', function(e) {
          if (e.target === $tci[0]) {
            $tci.find('.ui-selected').removeClass('ui-selected');
            return $tci.trigger('scaled_selectableunselected');
          }
        });
        return $tci.bind('scaled_selectableselected', function(e, sel) {
          var occupant, table, _ref;
          if (!$TC.chart.editable) {
            table = $$(sel.selected).sprite;
            occupant = (_ref = table.occupancy) != null ? _ref.occupant : void 0;
            if (!(occupant != null)) {
              return;
            }
            return $QUEUE.show_view_page(occupant.key);
          }
        });
      }
    });
  });
}).call(this);
