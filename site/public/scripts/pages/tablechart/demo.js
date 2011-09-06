(function() {
  $(function() {
    return $('#tablechart').live('pagecreate', function() {
      return $.when($D.charts.init()).then(function() {
        return $D.charts.ds.all(function(rows) {
          var l, opts, shape, size, x, y, _i, _j, _len, _len2, _ref, _ref2, _ref3;
          if (!rows || rows.length === 0) {
            _ref = [[100, 'RoundTable'], [200, 'RectTable']];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              _ref2 = _ref[_i], y = _ref2[0], shape = _ref2[1];
              x = 0;
              _ref3 = [1, 2, 6, 12, 24];
              for (_j = 0, _len2 = _ref3.length; _j < _len2; _j++) {
                size = _ref3[_j];
                x += 100;
                opts = {
                  seats: size,
                  x: x,
                  y: y,
                  shape: shape,
                  label: l = Math.floor(Math.random() * 100)
                };
                $TC.chart.add(opts, shape);
              }
            }
            return $TC.chart.save();
          }
        });
      });
    });
  });
}).call(this);
