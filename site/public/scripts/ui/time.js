(function() {
  var __slice = Array.prototype.slice, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  $.fn.time = function() {
    var TimeDisplay, args, def_opts, opts, time_disp;
    opts = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    if (!this.length) {
      return;
    }
    TimeDisplay = (function() {
      function TimeDisplay(elem, opts) {
        var _ref, _ref2;
        this.elem = elem;
        this.opts = opts;
        this.format = (_ref = (_ref2 = this.opts.format) != null ? _ref2 : $(this.elem).attr('data-format')) != null ? _ref : 'elapsed';
        this.set_interval();
        this.update();
      }
      TimeDisplay.prototype.set_interval = function(time) {
        if (time == null) {
          time = 60000;
        }
        if (this.update_freq === time) {
          return;
        }
        this.update_freq = time;
        if (this.interval != null) {
          clearInterval(this.interval);
        }
        return this.interval = setInterval(__bind(function() {
          return this.update();
        }, this), time);
      };
      TimeDisplay.prototype.toggle_format = function() {
        this.format = this.format === 'elapsed' ? 'remaining' : 'elapsed';
        this.elem.removeClass('overtime');
        return this.update();
      };
      TimeDisplay.prototype.update = function() {
        this.elapsed = Date.get_elapsed(this.elem.attr('datetime'));
        this.elem.attr('data-minutes', this.elapsed);
        this.target = parseFloat(this.elem.attr('data-target'));
        if (this.target === NaN) {
          this.target = null;
        }
        return this["_update_" + this.format]();
      };
      TimeDisplay.prototype._update_elapsed = function() {
        return this.elem.text($F.date.format_elapsed(this.elapsed));
      };
      TimeDisplay.prototype._update_remaining = function() {
        var rem, str, _ref, _ref2;
        if (!(this.target != null)) {
          this.elem.text('');
          return;
        }
        rem = this.target - this.elapsed;
        if (rem < 0) {
          this.elem.addClass('overtime');
        } else {
          this.elem.removeClass('overtime');
        }
        str = $F.date.format_remaining(rem, (_ref = this.opts.sign) != null ? _ref : true, (_ref2 = this.opts.sec) != null ? _ref2 : false);
        this.elem.text(str);
        if ((0 < rem && rem < 1)) {
          return this.set_interval(200);
        } else {
          return this.set_interval(60000);
        }
      };
      TimeDisplay.prototype._update_icon = function() {
        var canvas, canvas_jq, cxt, end_ang, per, rad, st_ang;
        if (!(this.target != null)) {
          return;
        }
        if (!this.elem.find('canvas').length) {
          this.elem.addClass('icon');
          canvas_jq = $('<canvas></canvas>');
          canvas_jq.addClass('icon-canvas');
          canvas_jq.attr('width', '20');
          canvas_jq.attr('height', '20');
          this.elem.append(canvas_jq);
          canvas = canvas_jq[0];
        } else {
          canvas = this.elem.find('canvas')[0];
        }
        cxt = canvas.getContext("2d");
        cxt.clearRect(0, 0, canvas.width, canvas.height);
        rad = canvas.width / 2;
        per = Math.abs(this.target - this.elapsed) / this.target;
        if (this.elapsed <= this.target) {
          per = 1 - per;
        }
        st_ang = -Math.PI * .5;
        end_ang = st_ang + per * Math.PI * 2;
        cxt.beginPath();
        cxt.arc(rad, rad, rad - .5, 0, Math.PI * 2, false);
        cxt.closePath();
        cxt.fillStyle = '#F0F0F0';
        cxt.fill();
        cxt.beginPath();
        cxt.moveTo(rad, rad);
        cxt.lineTo(rad, 0);
        cxt.arc(rad, rad, rad - .5 - 2, st_ang, end_ang, false);
        cxt.closePath();
        cxt.fillStyle = this.target <= this.elapsed ? "#D44" : "#666";
        return cxt.fill();
      };
      return TimeDisplay;
    })();
    if (typeof opts === 'string') {
      return this.each(function(i, elem) {
        var time_disp;
        time_disp = $$(elem).time_disp;
        return time_disp[opts].apply(time_disp, args);
      });
    } else {
      def_opts = {
        'type': 'string'
      };
      opts = $.extend({}, def_opts, opts);
      return time_disp = $$(this).time_disp = new TimeDisplay(this, opts);
    }
  };
}).call(this);
