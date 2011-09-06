(function() {
  var StatusList, list, _ref;
  var __hasProp = Object.prototype.hasOwnProperty, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  if ((_ref = window.$UI) == null) {
    window.$UI = {};
  }
  StatusList = (function() {
    function StatusList() {
      this.entries = [];
    }
    StatusList.prototype.register = function(entry) {
      return this.entries.push(entry);
    };
    return StatusList;
  })();
  list = new StatusList;
  $UI.Status = (function() {
    function Status() {
      list.register(this);
      this.shown = false;
    }
    Status.prototype.update = function(opts) {
      var action, name, _ref2;
      this.opts = opts;
      _ref2 = this.opts.actions;
      for (name in _ref2) {
        if (!__hasProp.call(_ref2, name)) continue;
        action = _ref2[name];
        if (typeof action === 'function') {
          this.opts.actions[name] = {
            func: action
          };
        }
      }
      return this.show();
    };
    Status.prototype._render_standalone = function() {
      var $a_el, $act, $clr, $con, $page, $st, act, name, self, text, _ref2, _ref3, _ref4;
      self = this;
      if (!(this.$el != null)) {
        this.$el = $('<div />');
        this.$el.addClass('status-standalone');
        $page = $('.ui-page-active');
        $page.find('.ui-content').prepend(this.$el);
        $('.ui-page').bind('pageshow', function() {
          self.$el.detach();
          return $(this).find('.ui-content').prepend(self.$el);
        });
      }
      this.$el.html('');
      this.$el.removeClass('notice warning error success');
      this.$el.addClass((_ref2 = this.opts.style) != null ? _ref2 : 'notice');
      if (this.opts.msg) {
        $con = $('<div />');
        $con.addClass('status-msg');
        $con.html(this.opts.msg);
        this.$el.append($con);
      }
      if (this.opts.actions) {
        $act = $('<div />');
        $act.addClass('actions');
        this.$el.append($act);
        _ref3 = this.opts.actions;
        for (name in _ref3) {
          if (!__hasProp.call(_ref3, name)) continue;
          act = _ref3[name];
          text = (_ref4 = act.text) != null ? _ref4 : name;
          if (act.status != null) {
            $st = $('<span />');
            $st.addClass('action-status');
            $st.html(act.status);
            $act.append($st);
            $st.find('time').time({
              format: 'remaining',
              sign: false,
              sec: true
            });
          }
          if (act.link === false) {
            $a_el = $('<span />');
          } else {
            $a_el = $('<a href="#do" />');
          }
          $a_el.html(text);
          if (act.style != null) {
            $a_el.addClass(act.style);
          }
          $a_el.find('a[href=#do]').andSelf().attr('data-action', name).bind('vclick', function(e) {
            var action;
            e.preventDefault();
            e.stopPropagation();
            action = self.opts.actions[$(this).attr('data-action')];
            action.func();
            return false;
          });
          $act.append($a_el);
        }
      }
      $clr = $('<hr />');
      $clr.addClass('clear');
      return this.$el.append($clr);
    };
    Status.prototype.update_action = function(name, opts) {
      var _base, _ref2;
      if ((_ref2 = (_base = this.opts.actions)[name]) == null) {
        _base[name] = {};
      }
      $.extend(this.opts.actions[name], opts);
      return this.show();
    };
    Status.prototype.render = function() {
      if (this.shown) {
        return this._render_standalone();
      }
    };
    Status.prototype.hide = function() {
      this.shown = false;
      if (this.$el != null) {
        this.$el.stop(true);
        return this.$el.slideUp();
      }
    };
    Status.prototype.show = function() {
      var timeout, _ref2;
      timeout = (_ref2 = this.opts.ttl) != null ? _ref2 : 500;
      if (this.show_timeout != null) {
        clearTimeout(this.show_timeout);
      }
      this.shown = true;
      if (timeout !== 0) {
        this.show_timeout = setTimeout(__bind(function() {
          return this.hide();
        }, this), timeout * 1000);
      }
      this.render();
      return this.$el.slideDown();
    };
    return Status;
  })();
}).call(this);
