(function() {
  var get_style, styles, _ref;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  styles = {
    "default": {
      fill: {
        color: '#F9F9F9'
      },
      line: {
        color: '#555',
        width: 2
      },
      label: {
        fill: {
          color: '#777'
        }
      },
      shadow: {
        x_offset: 0,
        y_offset: 0,
        blur: 0,
        color: 'white'
      },
      seat: {
        fill: {
          color: '#DDD'
        },
        line: {
          color: '#555'
        }
      }
    },
    selected: {
      line: {
        color: 'gold'
      },
      shadow: {
        blur: 10,
        color: 'rgba(250, 250, 0, 1)'
      }
    },
    occupied: {
      fill: {
        color: 'rgba(253, 178, 67, 1)'
      },
      label: {
        fill: {
          color: '#FCFCFC'
        }
      }
    },
    aligned: {
      line: {
        color: '#5393C5'
      },
      shadow: {
        blur: 10,
        color: '#85BAE4'
      }
    }
  };
  get_style = function(name) {
    return styles[name];
  };
  if ((_ref = window.$TC) == null) {
    window.$TC = {};
  }
  $TC.Sprite = (function() {
    __extends(Sprite, $U.Evented);
    function Sprite(opts) {
      this.opts = opts;
      Sprite.__super__.constructor.apply(this, arguments);
      this.ready = $.Deferred();
      if (!(this.opts.key != null)) {
        this.opts.key = Math.floor(Math.random() * 10000000000000);
      }
    }
    Sprite.prototype.canvas_ready = function() {
      return this.ready.promise();
    };
    Sprite.prototype.init = function(parent) {
      this.parent = parent;
      this.canvas = document.createElement('canvas');
      this.parent.appendChild(this.canvas);
      this.cxt = this.canvas.getContext('2d');
      this.$canvas = $(this.canvas);
      $$(this.canvas).sprite = this;
      this.w = this.h = 0;
      this.ready.resolve(this);
      this.style_stack = ['default'];
      return this.__defineGetter__('style_name', __bind(function() {
        return this.style_stack[this.style_stack.length - 1];
      }, this));
    };
    Sprite.prototype.push_style = function(name) {
      if (this.style_name !== name) {
        this.style_stack.push(name);
        return this.refresh();
      }
    };
    Sprite.prototype.pop_style = function(name) {
      if (this.style_stack.length > 1) {
        if (name != null) {
          this.style_stack.remove(name);
        } else {
          this.style_stack.pop();
        }
        return this.refresh();
      }
    };
    Sprite.prototype.package = function() {
      this.opts.x = this.x;
      this.opts.y = this.y;
      this.opts.seats = this.seats;
      return {
        opts: this.opts
      };
    };
    Sprite.prototype.destroy = function() {
      if (this.$canvas) {
        return this.$canvas.remove();
      }
    };
    Sprite.prototype._update_evt = function() {
      if (this.parent) {
        return $(this.parent).trigger('spriteUpdate', [this]);
      }
    };
    Sprite.prototype.update = function() {
      this._update_evt();
      return this.refresh();
    };
    Sprite.prototype.refresh = function() {
      if (this.cxt && this.parent) {
        this.cxt.clearRect(0, 0, this.w, this.h);
        return this.draw();
      }
    };
    Sprite.prototype.draw = function(parent) {
      if (!(this.parent != null) || ((parent != null) && this.parent !== parent)) {
        return this.init(parent);
      }
    };
    Sprite.prototype.move = function(x, y, corner) {
      if (corner == null) {
        corner = false;
      }
      if (corner) {
        x = x + this.w / 2;
        y = y + this.h / 2;
      }
      this.y = y != null ? y : this.y;
      this.x = x != null ? x : this.x;
      return this._move();
    };
    Sprite.prototype._move = function() {
      var x, y;
      y = this.y - this.h / 2;
      x = this.x - this.w / 2;
      this.canvas.style.top = y + 'px';
      return this.canvas.style.left = x + 'px';
    };
    Sprite.prototype._update_pos = function(x, y) {
      this.x = x + this.w / 2;
      return this.y = y + this.h / 2;
    };
    Sprite.prototype.size = function(w, h) {
      this.w = w;
      this.h = h;
      this.canvas.width = this.w;
      this.canvas.height = this.h;
      return this._move();
    };
    return Sprite;
  })();
  $TC.Table = (function() {
    __extends(Table, $TC.Sprite);
    Table.prototype.seat_width = 10;
    Table.prototype.seat_depth = 7;
    Table.prototype.seat_spacing = 3;
    function Table(opts) {
      var _ref2, _ref3;
      this.opts = opts;
      this.x = (_ref2 = opts.x) != null ? _ref2 : 0;
      this.y = (_ref3 = opts.y) != null ? _ref3 : 0;
      this.seats = this.opts.seats;
      this.occupancy = {};
      Table.__super__.constructor.call(this, this.opts);
    }
    Table.prototype.occupy = function(occupant) {
      this.occupancy.occupant = occupant != null ? occupant : null;
      if (occupant) {
        this.occupancy.time = new Date;
        return this.push_style('occupied');
      } else {
        return this.pop_style('occupied');
      }
    };
    Table.prototype._apply_style = function(section) {
      var r_style, style, _i, _len, _ref2, _ref3;
      this.style = {};
      _ref2 = this.style_stack;
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        style = _ref2[_i];
        r_style = get_style(style);
        $.extend(true, this.style, section != null ? r_style[section] : r_style);
      }
      if (section != null) {
        this.style = $.extend(true, {}, get_style('default'), this.style);
      }
      this.cxt.fillStyle = this.style.fill.color;
      this.cxt.strokeStyle = this.style.line.color;
      this.cxt.strokeWidth = this.style.line.width;
      this.cxt.font = (_ref3 = this.style.font) != null ? _ref3 : 'bold 1.6em sans-serif';
      if (this.style.shadow != null) {
        this.cxt.shadowOffsetX = this.style.shadow.x_offset;
        this.cxt.shadowOffsetY = this.style.shadow.y_offset;
        this.cxt.shadowBlur = this.style.shadow.blur;
        return this.cxt.shadowColor = this.style.shadow.color;
      }
    };
    Table.prototype.draw = function(parent) {
      var rot, _ref2;
      Table.__super__.draw.call(this, parent);
      rot = (_ref2 = this.opts.rotation) != null ? _ref2 : 0;
      this.$canvas.css('-moz-transform', "rotate(" + rot + "deg)");
      this.$canvas.css('-moz-transform-origin', "middle center");
      this._move();
      return this._draw();
    };
    Table.prototype._draw_circle = function(x, y, rad, style) {
      this._apply_style(style);
      this.cxt.beginPath();
      this.cxt.arc(x, y, rad, 0, Math.PI * 2, true);
      this.cxt.closePath();
      this.cxt.fill();
      return this.cxt.stroke();
    };
    Table.prototype._draw_seat = function(x, y, rot) {
      var pan_depth;
      if (rot == null) {
        rot = 0;
      }
      this.cxt.save();
      this._apply_style('seat');
      this.cxt.translate(x, y);
      this.cxt.rotate(rot + Math.PI / 2);
      pan_depth = this.seat_depth - this.seat_width / 2;
      this.cxt.beginPath();
      this.cxt.moveTo(-this.seat_width / 2, -pan_depth);
      this.cxt.lineTo(-this.seat_width / 2, 0);
      this.cxt.lineTo(this.seat_width / 2, 0);
      this.cxt.lineTo(this.seat_width / 2, -pan_depth);
      this.cxt.arc(0, -pan_depth, this.seat_width / 2, 0, Math.PI, true);
      this.cxt.closePath();
      this.cxt.fill();
      this.cxt.stroke();
      return this.cxt.restore();
    };
    Table.prototype._draw_rect = function(x, y, w, h, style) {
      this.cxt.save();
      this._apply_style(style);
      this.cxt.beginPath();
      this.cxt.moveTo(x, y);
      this.cxt.lineTo(x + w, y);
      this.cxt.lineTo(x + w, y + h);
      this.cxt.lineTo(x, y + h);
      this.cxt.closePath();
      this.cxt.fill();
      this.cxt.stroke();
      return this.cxt.restore();
    };
    Table.prototype._draw_centered_text = function(text, x, y, max_width, max_height, scale_bbox) {
      var ang, char_ratio, hyp, rot, size, _ref2;
      if (scale_bbox == null) {
        scale_bbox = true;
      }
      this.cxt.textAlign = 'center';
      this.cxt.textBaseline = 'middle';
      this.cxt.translate(x, y);
      if (this.opts.rotation) {
        this.opts.rotation %= 360;
        rot = this.opts.rotation / (180 / Math.PI);
        this.cxt.rotate(-rot);
        if (scale_bbox && this.opts.rotation !== 180) {
          if (this.opts.rotation % 90 === 0) {
            _ref2 = [max_width, max_height], max_height = _ref2[0], max_width = _ref2[1];
          } else {
            hyp = max_width;
            char_ratio = 3 / (text.length * 2.5);
            ang = Math.atan(char_ratio);
            max_height = Math.sin(ang) * hyp;
            max_width = Math.cos(ang) * hyp;
          }
        }
      }
      if (max_height < 30) {
        size = max_height * .8;
      } else {
        size = 30;
      }
      this.cxt.font = "bold " + size + "px sans-serif";
      return this.cxt.fillText(text, 0, 0, max_width);
    };
    Table.prototype._draw_fill_text = function(text, top, left, w, h) {
      this.cxt.textAlign = 'left';
      this.cxt.textBaseline = 'top';
      this.cxt.font = "bold " + (h * 1.3) + "px sans-serif";
      return this.cxt.fillText(text, left, top, w);
    };
    Table.prototype.draw_label = function(margin, scale_bbox) {
      var cx, cy, height, label, width;
      if (margin == null) {
        margin = [0, 0, 0, 0];
      }
      if (scale_bbox == null) {
        scale_bbox = true;
      }
      label = this.opts.label;
      if (!(label != null)) {
        return;
      }
      if (typeof label !== 'string') {
        label = label.toString();
      }
      this.cxt.save();
      this._apply_style('label');
      width = this.w - margin[1] - margin[3];
      height = this.h - margin[0] - margin[2];
      if (this.style.text_fit === 'fill') {
        this._draw_fill_text(label, margin[0], margin[3], width, height);
      } else {
        cx = width / 2 + margin[3];
        cy = height / 2 + margin[0];
        this._draw_centered_text(label, cx, cy, width, height, scale_bbox);
      }
      return this.cxt.restore();
    };
    Table.prototype.rotate = function(delta) {
      var _base, _ref2;
      if ((_ref2 = (_base = this.opts).rotation) == null) {
        _base.rotation = 0;
      }
      return this.opts.rotation += delta;
    };
    return Table;
  })();
  $TC.RoundTable = (function() {
    __extends(RoundTable, $TC.Table);
    function RoundTable() {
      RoundTable.__super__.constructor.apply(this, arguments);
    }
    RoundTable.prototype._draw = function() {
      var ang, center, circ, i, rad, square, x, y, _ref2;
      circ = this.seats * (this.seat_width + this.seat_spacing);
      rad = circ / Math.PI / 2;
      rad = Math.max(rad, 12);
      center = rad + this.seat_depth;
      this.size(2 * center, 2 * center);
      ang = 0;
      for (i = 0, _ref2 = this.seats; 0 <= _ref2 ? i < _ref2 : i > _ref2; 0 <= _ref2 ? i++ : i--) {
        ang += 2 * Math.PI / this.seats;
        x = Math.cos(ang) * rad + center;
        y = Math.sin(ang) * rad + center;
        this._draw_seat(x, y, ang);
      }
      this._draw_circle(center, center, rad);
      square = this.w / 2 - rad / Math.sqrt(2);
      return this.draw_label([square, square, square, square], false);
    };
    RoundTable.prototype.rotate = function() {};
    return RoundTable;
  })();
  $TC.RectTable = (function() {
    __extends(RectTable, $TC.Table);
    function RectTable() {
      RectTable.__super__.constructor.apply(this, arguments);
    }
    RectTable.prototype.width = 28;
    RectTable.prototype.single_width = 20;
    RectTable.prototype._draw = function() {
      var height, i, margin, out_height, out_width, seats_left, side_seats, width, x, y;
      width = this.seats > 1 ? this.width : this.single_width;
      side_seats = Math.floor(this.seats / 2);
      height = side_seats * (this.seat_width + this.seat_spacing) + this.seat_spacing;
      height = Math.max(height, this.seat_width + 2 * this.seat_spacing);
      out_width = width;
      if (this.seats > 1) {
        out_width += 2 * this.seat_depth;
      }
      out_height = height;
      if (this.seats & 1) {
        out_height += this.seat_depth;
      }
      this.size(out_width, out_height);
      if (this.seats <= 1) {
        this._draw_seat(width / 2, height, Math.PI / 2);
        this._draw_rect(0, 0, width, height);
      } else {
        seats_left = this.seats;
        x = this.seat_depth;
        y = this.seat_spacing + this.seat_width / 2;
        for (i = 0; 0 <= side_seats ? i < side_seats : i > side_seats; 0 <= side_seats ? i++ : i--) {
          seats_left -= 2;
          this._draw_seat(x, y, Math.PI);
          this._draw_seat(x + width, y, 0);
          y += this.seat_width + this.seat_spacing;
        }
        if (seats_left) {
          this._draw_seat(this.seat_depth + width / 2, height, Math.PI / 2);
        }
        this._draw_rect(this.seat_depth, 0, width, height);
      }
      margin = [0, 0, 0, 0];
      if (this.seats & 1) {
        margin[2] = this.seat_depth;
      }
      if (this.seats > 1) {
        margin[1] = margin[3] = this.seat_depth;
      }
      return this.draw_label(margin);
    };
    RectTable.prototype.rotate = function(delta) {
      RectTable.__super__.rotate.call(this, delta);
      return this.opts.rotation %= 180;
    };
    return RectTable;
  })();
}).call(this);
