(function() {
  var BASE_HEIGHT, BASE_WIDTH, MIN_SCALE, _ref;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  if ((_ref = window.$TC) == null) {
    window.$TC = {};
  }
  $TC.scroller = null;
  BASE_HEIGHT = 720.0;
  BASE_WIDTH = 1280.0;
  MIN_SCALE = 0.5;
  $(function() {
    var $contain, $page, $tc, $tci;
    $page = $('#tablechart');
    $tc = $('.tablechart', $page);
    $tci = $('.tablechart-inner', $page);
    $contain = $('.tc-container', $page);
    $TC.chart = new $TC.Chart($tci[0]);
    $tci.bind('spriteUpdate', function() {
      return $TC.chart.save();
    });
    $page.bind('optionChange', function(e, field, val) {
      if (field === 'edit') {
        return $TC.chart.set_editable(val === 'unlocked');
      }
    });
    return $page.bind('pageshow', function() {
      var $this, $win, fact, opts, update_size;
      $this = $(this);
      $TC.chart.draw();
      update_size = __bind(function() {
        var center, fact, height, max_fact, min_fact, width, x_fact, y_fact, _ref2;
        $('html').removeClass('landscape portrait');
        _ref2 = $UI.get_page_space($page), width = _ref2[0], height = _ref2[1];
        x_fact = width / BASE_WIDTH;
        y_fact = height / BASE_HEIGHT;
        max_fact = Math.max(x_fact, y_fact);
        min_fact = Math.min(x_fact, y_fact);
        if (min_fact > MIN_SCALE) {
          fact = min_fact;
          center = true;
        } else {
          fact = max_fact;
          center = false;
        }
        $tci.css('left', 0).css('top', 0);
        if (center) {
          if (min_fact === y_fact) {
            $tci.css('left', ((width - fact * BASE_WIDTH) / 2.0) * 1 / fact + 'px');
          } else {
            $tci.css('top', ((height - fact * BASE_HEIGHT) / 2.0) * 1 / fact + 'px');
          }
        }
        $contain.height(height + 'px');
        $tc.height(BASE_HEIGHT + 'px');
        $tc.width(BASE_WIDTH + 'px');
        if ($TC.scroller != null) {
          setTimeout(function() {
            $TC.scroller.refresh();
            $TC.scroller.zoom(0, 0, fact, 0);
            if (center) {
              $TC.scroller._resetPos(0);
            }
            return $TC.scroller._end({}, false);
          }, 0);
        }
        return fact;
      }, this);
      fact = update_size();
      $win = $(window);
      $win.bind('resize', update_size);
      $win.bind('beforepageshow', function() {
        return $win.unbind('resize', update_size);
      });
      if (!($TC.scroller != null)) {
        opts = {
          lockDirection: false,
          hScrollbar: true,
          zoom: true,
          zoomMax: 6,
          zoomMin: .1
        };
        $TC.scroller = new iScroll($contain[0], opts);
        update_size();
        $CTRL_KEYS.bind('ctrldown', function() {
          return $TC.scroller.enabled = false;
        });
        return $CTRL_KEYS.bind('ctrlup', function() {
          return $TC.scroller.enabled = true;
        });
      }
    });
  });
}).call(this);
