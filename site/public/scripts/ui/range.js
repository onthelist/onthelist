(function() {
  $(function() {
    return $('[data-role=dialog], [data-role=page]').live('pagecreate', function() {
      var def_speed, mousedown, ranges, speed_scale, timeout, wait_time;
      mousedown = false;
      timeout = false;
      wait_time = 600;
      def_speed = 400;
      speed_scale = 7.0;
      ranges = $('input[data-type=range]', this);
      ranges.bind('forceVal', function(e, val) {
        var max, min;
        max = this.getAttribute('max');
        if ((max != null) && parseInt(max) < val) {
          this.setAttribute('max', val);
        }
        min = this.getAttribute('min');
        if ((min != null) && parseInt(min) > val) {
          this.setAttribute('min', val);
        }
        this.value = val;
        return $(this).slider('refresh');
      });
      ranges.change(function() {
        var step, val;
        if (this.getAttribute('step')) {
          val = parseInt(this.value);
          step = parseInt(this.getAttribute('step'));
          return this.value = val - (val % step);
        }
      });
      ranges.change(function() {
        var self, set_timeout, speed, step, up;
        if (mousedown && !timeout && this.value === this.getAttribute('max')) {
          self = $(this);
          speed = def_speed;
          step = parseInt(self.attr('step') || '1');
          set_timeout = function(s) {
            if (s == null) {
              s = speed;
            }
            return timeout = setTimeout(up, s);
          };
          up = function() {
            if (mousedown && self.val() === self.attr('max')) {
              speed -= speed / speed_scale;
              speed = Math.max(speed, 10);
              set_timeout();
              self.attr('max', parseInt(self.attr('max')) + step);
              self.val(self.attr('max'));
              return self.slider('refresh');
            } else {
              return timeout = false;
            }
          };
          return set_timeout(wait_time);
        }
      });
      $('.ui-slider-handle', this).bind('mousedown vmousedown', function() {
        return mousedown = true;
      }).bind('mouseup vmouseup', function() {
        mousedown = false;
        return true;
      });
      return $(document).bind('mouseup vmouseup', function() {
        return mousedown = false;
      });
    });
  });
}).call(this);
