(function() {
  var SwipeMenu;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  SwipeMenu = (function() {
    function SwipeMenu($elem, opts) {
      this.$elem = $elem;
      this.opts = opts;
      this._bind_events();
    }
    SwipeMenu.prototype._bind_events = function() {
      this.$elem.bind('dragstart', function() {
        return false;
      });
      this.$elem.bind('swiperight showSwipeMenu', __bind(function() {
        this._show_buttons();
        return true;
      }, this));
      return this.$elem.bind('swipeleft vclick hideSwipeMenu', __bind(function() {
        this._hide_buttons();
        return true;
      }, this));
    };
    SwipeMenu.prototype._show_buttons = function() {
      var $button, action, _i, _len, _ref, _ref2;
      this.$b_cont = $('<div />');
      this.$b_cont.addClass('swipe-button-container');
      this.$slide_cont = $('<div />');
      this.$slide_cont.addClass('swipe-button-slide');
      this.$b_cont.append(this.$slide_cont);
      this.$elem.append(this.$b_cont);
      _ref = this.opts.actions;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        action = _ref[_i];
        $button = $('<a />');
        $button.text(action.label);
        $button.bind('vclick', (__bind(function(action) {
          return __bind(function(e) {
            e.stopPropagation();
            e.preventDefault();
            action.cb();
            return this._hide_buttons();
          }, this);
        }, this))(action));
        this.$slide_cont.append($button);
        $button.buttonMarkup({
          inline: true,
          theme: (_ref2 = action.theme) != null ? _ref2 : 'b'
        });
      }
      return this.$b_cont.css('width', 0).animate({
        'width': '200px'
      }, 200);
    };
    SwipeMenu.prototype._hide_buttons = function() {
      if (this.$b_cont != null) {
        return this.$b_cont.animate({
          'width': 0
        }, 200, 'swing', __bind(function() {
          return this.$b_cont.remove();
        }, this));
      }
    };
    return SwipeMenu;
  })();
  jQuery.fn.swipe_menu = function(opts) {
    return new SwipeMenu($(this), opts);
  };
}).call(this);
