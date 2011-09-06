(function() {
  var GuestSearchBox;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __slice = Array.prototype.slice;
  GuestSearchBox = (function() {
    function GuestSearchBox($elem, opts) {
      this.$elem = $elem;
      this.opts = opts != null ? opts : {};
      this.last_val = this.$elem.val();
      this.$elem.bind('keyup change', __bind(function(e) {
        return this._handle_change(e);
      }, this));
      this.request = null;
      this.wait_timer = null;
      this.match = null;
      this.queue = $D.parties;
      this._add_button();
    }
    GuestSearchBox.prototype._pos_button = function() {
      var left, pos, w;
      pos = this.$elem.position();
      w = this.$elem.outerWidth();
      left = pos.left + w - this.$button.outerWidth();
      this.$button.css('left', "" + left + "px");
      return this.$button.css('height', "" + (this.$elem.height()) + "px");
    };
    GuestSearchBox.prototype._add_button = function() {
      this.$button = $('<div></div>');
      this.$button.buttonMarkup({
        theme: 'c'
      });
      this.$button.addClass('infield-button ui-corner-right empty');
      this.$button.removeClass('ui-btn-corner-all');
      this.$elem.parent().append(this.$button);
      this._pos_button();
      $(window).bind('resize', __bind(function() {
        return this._pos_button();
      }, this));
      this.$button.bind('vclick', __bind(function(e) {
        if ((this.match != null) && this._check_match(this.match, this.$elem.val())) {
          this.$elem.caret(0, 0);
          return this.$elem.trigger('fill', [this.match, this, 'click']);
        }
      }, this));
      return this.$elem.bind('blur', __bind(function(e) {
        if ((this.match != null) && this._check_match(this.match, this.$elem.val())) {
          this.$elem.caret(0, 0);
          return this.$elem.trigger('fill', [this.match, this, 'blur']);
        }
      }, this));
    };
    GuestSearchBox.prototype._strip_typed_ahead = function(val, evt) {
      if ((this.typed_ahead != null) && val.length > this.typed_ahead.length && val.indexOf(this.typed_ahead) === val.length - this.typed_ahead.length) {
        val = val.substring(0, val.length - this.typed_ahead.length);
        if ((evt.keyCode != null) && evt.keyCode === this.typed_ahead.charCodeAt(0)) {
          val += this.typed_ahead[0];
        }
      }
      return val;
    };
    GuestSearchBox.prototype._handle_change = function(evt) {
      var val;
      val = this.$elem.val();
      this.entered = val;
      if (evt.keyCode === 8) {
        if (this.match && this.typed_ahead) {
          val = val.substring(0, val.length - 1);
          this.$elem.val(val);
          this.typed_ahead = false;
        }
      }
      if (val === this.last_val) {
        return true;
      }
      this._abort_active();
      this.last_val = val;
      if (this.match && this._check_match(this.match, val)) {
        this.entered = this._strip_typed_ahead(val, evt);
        this._type_ahead();
        return true;
      } else {
        this.match = null;
      }
      if (val.length < 3) {
        return true;
      }
      if (this.wait_timer != null) {
        clearTimeout(this.wait_timer);
      }
      this.wait_timer = setTimeout(__bind(function() {
        return this._match(val);
      }, this), 100);
      return true;
    };
    GuestSearchBox.prototype._abort_active = function() {
      if (this.request != null) {
        this.request.abort();
        return this.request = null;
      }
    };
    GuestSearchBox.prototype._check_match = function(row, val) {
      var indx, _ref;
      if (!(val != null) || !val.length) {
        return false;
      }
      indx = (_ref = row[this.opts.field]) != null ? _ref.indexOf(val) : void 0;
      if (indx === -1 || !(indx != null)) {
        return false;
      }
      return this.opts.match_anywhere || indx === 0;
    };
    GuestSearchBox.prototype._match = function(val) {
      this._button_loading();
      return this.queue.find(__bind(function(r) {
        return this._check_match(r, val);
      }, this), __bind(function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return this._handle_match.apply(this, args);
      }, this));
    };
    GuestSearchBox.prototype._handle_match = function(resp) {
      if (resp.length === 0) {
        this.match = null;
        this._button_empty();
        return;
      }
      this.match = resp[0];
      if (this.$elem.triggerHandler('match', [this.match, this]) === false) {
        this.match = null;
        return;
      }
      this._button_ready();
      return this._type_ahead();
    };
    GuestSearchBox.prototype._type_ahead = function() {
      var val;
      if (this.$elem.triggerHandler('typeAhead', [this.match, this]) === false) {
        return;
      }
      if (!this.$elem.is(':focus')) {
        return;
      }
      val = this.match[this.opts.field];
      if (this.opts.format_type_ahead != null) {
        val = this.opts.format_type_ahead(val);
      }
      this.$elem.val(val);
      this.typed_ahead = val.substring(this.entered.length);
      return this.$elem.caret(this.entered.length, val.length);
    };
    GuestSearchBox.prototype._button_empty = function() {
      this.$button.text('');
      this.$button.removeClass('ready loading');
      return this.$button.addClass('empty');
    };
    GuestSearchBox.prototype._button_ready = function() {
      this.$button.text('↴');
      this.$button.addClass('ready');
      return this.$button.removeClass('loading empty');
    };
    GuestSearchBox.prototype._button_loading = function() {
      this.$button.text('');
      this.$button.addClass('loading');
      return this.$button.removeClass('ready empty');
    };
    return GuestSearchBox;
  })();
  $.fn.guest_search = function(opts) {
    if (opts == null) {
      opts = {};
    }
    $$(this).guest_search = new GuestSearchBox(this, opts);
    return this;
  };
}).call(this);
