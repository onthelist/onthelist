(function() {
  var Menu;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  Menu = (function() {
    function Menu($elem, opts) {
      this.$elem = $elem;
      this.opts = opts;
      this.submenu = this.fields = this.opts.fields;
      this._create_select();
      this._init_menu();
      this.menu_stack = [];
      this._update_menu_tab();
      $('.ui-page').bind('pageshow', __bind(function() {
        return this._update_menu_tab();
      }, this));
    }
    Menu.prototype._get_field = function(name, fields) {
      var field, _i, _len, _ref;
      if (fields == null) {
        fields = this.submenu;
      }
      _ref = fields.options;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        field = _ref[_i];
        if (field.name === name) {
          return field;
        }
      }
      return null;
    };
    Menu.prototype._update_menu_tab = function() {
      if (this.$elem.find('a.ui-btn-icon-top').hasClass('ui-btn-active')) {
        return this._menu_tab(false);
      } else {
        return this._menu_tab(true);
      }
    };
    Menu.prototype._menu_tab = function(revert) {
      if (revert == null) {
        revert = false;
      }
      if (!revert) {
        if (!(this.icon != null)) {
          this.icon = this.$elem.find('a.ui-btn-icon-top').attr('data-icon');
        }
        if (!(this.elem_text != null)) {
          this.elem_text = this.$elem.find('.ui-btn-text').text();
        }
        this.$elem.find('.ui-icon').removeClass("ui-icon-" + this.icon).addClass('ui-icon-arrow-u');
        return this.$elem.find('.ui-btn-text').text("Page Menu");
      } else {
        this.$elem.find('.ui-icon').removeClass('ui-icon-arrow-u').addClass("ui-icon-" + this.icon);
        return this.$elem.find('.ui-btn-text').text(this.elem_text);
      }
    };
    Menu.prototype._create_select = function() {
      this.$sel = $('<select></select>');
      this.$sel.addClass('select-menu list-control');
      this.$elem.append(this.$sel);
      return this._create_options();
    };
    Menu.prototype._create_options = function(fields) {
      var $back, $opt, field, _i, _len, _ref;
      if (fields == null) {
        fields = this.fields;
      }
      this.$sel.html('');
      this.$sel.append($('<option></option>'));
      if (this.submenu !== this.fields) {
        $back = $('<option></option>');
        $back.text('< Back');
        $back.val('#back');
        this.$sel.append($back);
      }
      _ref = fields.options;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        field = _ref[_i];
        $opt = $('<option></option>');
        $opt.attr('value', field.name);
        this._update_option($opt, field, fields.value);
        this.$sel.append($opt);
      }
      if (fields.value != null) {
        this.$sel.val(fields.value);
      }
      if (this.menu != null) {
        return this.menu.refresh(true);
      }
    };
    Menu.prototype._init_menu = function() {
      this.$sel.selectmenu({
        nativeMenu: false
      });
      this.menu = this.$sel.jqmData().selectmenu;
      this.$elem.find('.ui-select').last().hide();
      return this.$sel.change(__bind(function() {
        var field, val;
        val = this.$sel.val();
        this.$sel.val(null);
        field = this._get_field(val);
        if ((field != null ? field.type : void 0) === 'toggle') {
          return this._toggle_val(val);
        } else if (this.submenu === this.fields) {
          return this._show_submenu(val);
        } else if (val === '#back') {
          return this._hide_submenu();
        } else {
          return this._set_val(val);
        }
      }, this));
    };
    Menu.prototype._update_option = function($opt, field, parent_val) {
      var lbl, opt, text, _i, _len, _ref;
      text = '';
      if (field.value != null) {
        _ref = field.options;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          opt = _ref[_i];
          if (field.value === opt.name) {
            lbl = opt.label;
          }
        }
        if (field.label != null) {
          text = "" + field.label + ": ";
        }
        text += lbl;
      } else {
        text = field.label;
      }
      return $opt.text(text);
    };
    Menu.prototype._show_submenu = function(name, push, show) {
      var field, _ref;
      if (push == null) {
        push = true;
      }
      if (show == null) {
        show = true;
      }
      field = (_ref = this._get_field(name)) != null ? _ref : this.fields;
      this.submenu = field;
      this._create_options(field);
      if (name && push) {
        this.menu_stack.push(name);
      }
      if (show) {
        return setTimeout(__bind(function() {
          return this.show();
        }, this), 0);
      }
    };
    Menu.prototype._set_val = function(val) {
      this.submenu.value = val;
      this.$elem.trigger('optionChange', [this.submenu.name, val]);
      return this._hide_submenu(true, false);
    };
    Menu.prototype._toggle_val = function(val) {
      var field, opt, _i, _len, _ref, _results;
      field = this._get_field(val);
      _ref = field.options;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        opt = _ref[_i];
        if (opt.name !== field.value) {
          field.value = opt.name;
          this.$elem.trigger('optionChange', [val, field.value]);
          this._create_options(this.submenu);
          break;
        }
      }
      return _results;
    };
    Menu.prototype._hide_submenu = function(to_root, show) {
      var name, _ref;
      if (to_root == null) {
        to_root = false;
      }
      if (show == null) {
        show = true;
      }
      if (to_root) {
        this.menu_stack = [];
      } else {
        this.menu_stack.pop();
      }
      name = (_ref = this.menu_stack.last()) != null ? _ref : null;
      return this._show_submenu(name, false, show);
    };
    Menu.prototype.show = function() {
      var left, top;
      this.$sel.selectmenu('open');
      top = this.$elem.offset().top - this.menu.listbox.height() - 14;
      this.menu.listbox.css('top', top);
      left = this.$elem.offset().left + 30;
      this.menu.listbox.css('left', left);
      return this.menu.listbox.find('.ui-btn-active').removeClass('ui-btn-active');
    };
    Menu.prototype.hide = function() {
      return this.$sel.selectmenu('close');
    };
    Menu.prototype.toggle = function() {
      if (!this.menu.isOpen) {
        return this.show();
      } else {
        return this.hide();
      }
    };
    return Menu;
  })();
  $.fn.menu = function(opts) {
    if (typeof opts === 'string') {
      return $$(this).menu[opts]();
    }
    return $$(this).menu = new Menu(this, opts);
  };
}).call(this);
