(function() {
  var DraggableSprite;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  DraggableSprite = (function() {
    function DraggableSprite(sprite, chart) {
      this.sprite = sprite;
      this.chart = chart;
      this._e_drag_stop = __bind(this._e_drag_stop, this);
      this._e_drag_start = __bind(this._e_drag_start, this);
      this._e_drag = __bind(this._e_drag, this);
      this.modifiers = [];
      $.when(this.sprite.canvas_ready()).then(__bind(function() {
        return this.init();
      }, this));
      this.register_modifier(this._correct_zoom);
      this.register_modifier(this._snap);
      this.register_modifier(this._include_selected);
      this.register_modifier(this._move_menu);
      this.register_modifier(this._update_pos);
    }
    DraggableSprite.prototype.register_modifier = function(func) {
      return this.modifiers.push(func);
    };
    DraggableSprite.prototype._drag = function(ui) {
      var m, _i, _len, _ref, _results;
      _ref = this.modifiers;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        m = _ref[_i];
        _results.push(m.call(this, ui, this.sprite.canvas));
      }
      return _results;
    };
    DraggableSprite.prototype._start = function(ui) {
      var name, prop, _results;
      _results = [];
      for (name in this) {
        prop = this[name];
        _results.push(name.startsWith('_start_') ? prop.call(this, ui) : void 0);
      }
      return _results;
    };
    DraggableSprite.prototype._stop = function(ui) {
      var name, prop, _results;
      _results = [];
      for (name in this) {
        prop = this[name];
        _results.push(name.startsWith('_stop_') ? prop.call(this, ui) : void 0);
      }
      return _results;
    };
    DraggableSprite.prototype._move_menu = function(ui) {
      var $menu, p;
      $menu = $('#tablechart .editor');
      p = ui.position;
      if ($menu.hasClass('docked-left') && p.left < $menu.width()) {
        $menu.removeClass('docked-left');
        return $menu.addClass('docked-right');
      } else if ($menu.hasClass('docked-right') && p.left > ($(document).width() - $menu.width())) {
        $menu.removeClass('docked-right');
        return $menu.addClass('docked-left');
      }
    };
    DraggableSprite.prototype._start_include_selected = function() {
      var c, elem, sel, _i, _len, _results;
      c = this.$canvas.position();
      sel = $('.ui-selected', this.chart.cont);
      this._include_selected_selection = [];
      _results = [];
      for (_i = 0, _len = sel.length; _i < _len; _i++) {
        elem = sel[_i];
        _results.push(elem !== this.sprite.canvas ? this._include_selected_selection.push({
          sprite: $$(elem).sprite,
          delta: {
            left: parseFloat(elem.style.left) - c.left,
            top: parseFloat(elem.style.top) - c.top
          }
        }) : void 0);
      }
      return _results;
    };
    DraggableSprite.prototype._stop_include_selected = function() {
      return this._include_selected_selection = [];
    };
    DraggableSprite.prototype._include_selected = function(ui) {
      var p, rec, _i, _len, _ref, _results;
      p = ui.position;
      _ref = this._include_selected_selection;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        rec = _ref[_i];
        _results.push(rec.sprite.move(p.left + rec.delta.left, p.top + rec.delta.top, true));
      }
      return _results;
    };
    DraggableSprite.prototype._get_center = function(ui) {
      var p;
      p = ui.position;
      return {
        top: p.top + this.$canvas.outerHeight() / 2,
        left: p.left + this.$canvas.outerWidth() / 2
      };
    };
    DraggableSprite.prototype._snap = function(ui) {
      var THRESHOLD, c, diff, p, sprite, x_closest, x_diff, x_gap, x_gap_diff, x_list, x_max, x_min, x_pos, y_closest, y_diff, y_gap, y_gap_diff, y_list, y_max, y_min, y_pos, _clear_lines, _draw_line, _find_closest_gap, _i, _j, _k, _len, _len2, _len3, _ref, _ref2, _ref3, _ref4, _ref5, _ref6;
      THRESHOLD = 5;
      p = ui.position;
      c = this._get_center(ui);
      if ((_ref = this._snap_lines) == null) {
        this._snap_lines = [];
      }
      _draw_line = __bind(function(x1, y1, x2, y2) {
        var $line, WIDTH;
        WIDTH = 4;
        $line = $('<div></div>');
        $line.addClass('snap-guide ui-bar-b');
        $line.css('position', 'absolute');
        if (x1 === x2) {
          $line.css('left', Math.min(x1, x2) - WIDTH / 2);
          $line.css('top', Math.min(y1, y2));
          $line.css('width', WIDTH);
          $line.css('height', Math.abs(y2 - y1));
        } else {
          $line.css('left', Math.min(x1, x2));
          $line.css('top', Math.min(y1, y2) - WIDTH / 2);
          $line.css('height', WIDTH);
          $line.css('width', Math.abs(x2 - x1));
        }
        $(this.chart.cont).append($line);
        return this._snap_lines.push($line);
      }, this);
      _clear_lines = __bind(function() {
        var $line, sprite, _i, _j, _len, _len2, _ref2, _ref3;
        _ref2 = this._snap_lines;
        for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
          $line = _ref2[_i];
          $line.remove();
        }
        this._snap_lines = [];
        if (this._snap_matched != null) {
          _ref3 = this._snap_matched;
          for (_j = 0, _len2 = _ref3.length; _j < _len2; _j++) {
            sprite = _ref3[_j];
            sprite.pop_style();
          }
          return this._snap_matched = [];
        }
      }, this);
      _clear_lines();
      this._snap_matched = [];
      this.$canvas.bind('dragstop', _clear_lines);
      $TC.gaps = {};
      x_pos = y_pos = x_diff = y_diff = null;
      x_list = [];
      y_list = [];
      _ref2 = this.chart.sprites;
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        sprite = _ref2[_i];
        if (sprite === this.sprite) {
          continue;
        }
        if (sprite.x + THRESHOLD > c.left && sprite.x - THRESHOLD < c.left) {
          x_list.push(sprite.y - c.top);
          diff = Math.abs(sprite.x - c.left);
          if (!(x_diff != null) || diff < x_diff) {
            x_pos = sprite.x;
            x_diff = diff;
          }
        } else if (sprite.y + THRESHOLD > c.top && sprite.y - THRESHOLD < c.top) {
          y_list.push(sprite.x - c.left);
          diff = Math.abs(sprite.y - c.top);
          if (!(y_diff != null) || diff < y_diff) {
            y_pos = sprite.y;
            y_diff = diff;
          }
        } else {
          continue;
        }
        this._snap_matched.push(sprite);
      }
      if (!this._snap_matched.length) {
        return;
      }
      this._snap_matched.push(this.sprite);
      _ref3 = this._snap_matched;
      for (_j = 0, _len2 = _ref3.length; _j < _len2; _j++) {
        sprite = _ref3[_j];
        sprite.push_style('aligned');
      }
      if ((x_pos != null) || (y_pos != null)) {
        x_min = x_max = c.left;
        y_min = y_max = c.top;
        x_closest = y_closest = null;
        _ref4 = this.chart.sprites;
        for (_k = 0, _len3 = _ref4.length; _k < _len3; _k++) {
          sprite = _ref4[_k];
          if (sprite === this.sprite) {
            continue;
          }
          if (x_pos && Math.abs(sprite.x - x_pos) < THRESHOLD) {
            if (sprite.y < y_min) {
              y_min = sprite.y;
            }
            if (sprite.y > y_max) {
              y_max = sprite.y;
            }
            if (x_pos !== sprite.x) {
              sprite.move(x_pos, null);
            }
          }
          if (y_pos && Math.abs(sprite.y - y_pos) < THRESHOLD) {
            if (sprite.x < x_min) {
              x_min = sprite.x;
            }
            if (sprite.x > x_max) {
              x_max = sprite.x;
            }
            if (y_pos !== sprite.y) {
              sprite.move(null, y_pos);
            }
          }
        }
        _find_closest_gap = __bind(function(list) {
          var closest, gap, l, second, _l, _len4, _ref5;
          list.sortBy(Math.abs);
          closest = list[0];
          second = null;
          _ref5 = list.slice(1);
          for (_l = 0, _len4 = _ref5.length; _l < _len4; _l++) {
            l = _ref5[_l];
            if ((closest >= 0) === (l >= 0)) {
              second = l;
              break;
            }
          }
          if (!(second != null)) {
            return [null, null];
          }
          gap = -(second - closest);
          diff = -(-gap - closest);
          return [gap, diff];
        }, this);
        if (x_pos) {
          p.left += x_pos - c.left;
          _draw_line(x_pos, y_min, x_pos, y_max);
          if (!y_pos) {
            _ref5 = _find_closest_gap(x_list), y_gap = _ref5[0], y_gap_diff = _ref5[1];
            if (y_gap) {
              $TC.gaps.y = y_gap;
              $TC.gaps.x = 0;
              _draw_line(x_pos - 8, c.top + y_gap_diff, x_pos + 8, c.top + y_gap_diff);
            }
            if (Math.abs(y_gap_diff) < THRESHOLD) {
              p.top += y_gap_diff;
            }
          }
        }
        if (y_pos) {
          p.top += y_pos - c.top;
          _draw_line(x_min, y_pos, x_max, y_pos);
          if (!x_pos) {
            _ref6 = _find_closest_gap(y_list), x_gap = _ref6[0], x_gap_diff = _ref6[1];
            if (x_gap) {
              $TC.gaps.x = x_gap;
              $TC.gaps.y = 0;
              _draw_line(c.left + x_gap_diff, y_pos - 8, c.left + x_gap_diff, y_pos + 8);
              if (Math.abs(x_gap_diff) < THRESHOLD) {
                return p.left += x_gap_diff;
              }
            }
          }
        }
      }
    };
    DraggableSprite.prototype._correct_zoom = function(ui) {
      var o, p;
      p = ui.position;
      o = ui.originalPosition;
      p.top = o.top + (p.top - o.top) * 1 / $TC.scroller.scale;
      return p.left = o.left + (p.left - o.left) * 1 / $TC.scroller.scale;
    };
    DraggableSprite.prototype._shift_scroll = function(ui) {
      var $content, height, p, s, width, x_shift, y_shift, _ref;
      p = ui.position;
      $content = $('.ui-page-active .ui-content');
      _ref = [$content.width(), $content.height()], width = _ref[0], height = _ref[1];
      s = $TC.scroller;
      x_shift = y_shift = 0;
      if (-s.x > p.left) {
        x_shift = -(p.left + s.x);
      } else if (width - s.x < p.left) {
        x_shift = -(p.left - (width - s.x));
      }
      if (-s.y > p.top) {
        y_shift = -(p.top + s.y);
      } else if (height - s.y < p.top) {
        y_shift = -(p.top - (height - s.y));
      }
      if (x_shift || y_shift) {
        s.scrollTo(s.x + x_shift, s.y + y_shift, 0);
      }
      p.top -= y_shift * $TC.scroller.scale;
      return p.left -= x_shift * $TC.scroller.scale;
    };
    DraggableSprite.prototype._update_pos = function(ui) {
      var p;
      p = ui.position;
      return this.sprite._update_pos(p.left, p.top);
    };
    DraggableSprite.prototype.destroy = function() {
      return this.$canvas.draggable('destroy').unbind('drag', this._e_drag).unbind('dragstart', this._e_drag_start).unbind('dragstop', this._e_drag_stop).unbind('touchstart mousedown', this._e_mouse_down).unbind('touchend mouseup mouseout', this._e_mouse_up);
    };
    DraggableSprite.prototype._e_drag = function(e, ui) {
      return this._drag(ui);
    };
    DraggableSprite.prototype._e_drag_start = function(e, ui) {
      if (!this.$canvas.hasClass('ui-selected')) {
        this.$canvas.trigger('select');
      }
      return this._start(ui);
    };
    DraggableSprite.prototype._e_drag_stop = function(e, ui) {
      this.sprite._update_evt();
      return this._stop(ui);
    };
    DraggableSprite.prototype._e_mouse_down = function() {
      $TC.scroller.enabled = false;
      return true;
    };
    DraggableSprite.prototype._e_mouse_up = function() {
      $TC.scroller.enabled = true;
      return true;
    };
    DraggableSprite.prototype.init = function() {
      this.$canvas = $(this.sprite.canvas);
      return this.$canvas.draggable({
        opacity: 0.5,
        containment: 'parent'
      }).bind('touchstart mousedown', this._e_mouse_down).bind('touchend mouseup mouseout', this._e_mouse_up).bind('drag', this._e_drag).bind('dragstart', this._e_drag_start).bind('dragstop', this._e_drag_stop);
    };
    return DraggableSprite;
  })();
  $TC.draggable_sprite = function(elem, cont) {
    return $$(elem).draggable_sprite = new DraggableSprite(elem, cont);
  };
}).call(this);
