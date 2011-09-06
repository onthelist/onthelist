(function() {
  var _ref;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  if ((_ref = window.$TC) == null) {
    window.$TC = {};
  }
  $TC.Chart = (function() {
    __extends(Chart, $U.Evented);
    function Chart(cont, opts) {
      var _base, _base2, _ref2, _ref3, _ref4;
      this.cont = cont;
      this.opts = opts != null ? opts : {};
      Chart.__super__.constructor.apply(this, arguments);
      this.sprites = [];
      if ((_ref2 = (_base = this.opts).name) == null) {
        _base.name = 'Default Chart';
      }
      if ((_ref3 = (_base2 = this.opts).key) == null) {
        _base2.key = this.opts.name.toLowerCase().remove(' ');
      }
      this.editable = (_ref4 = this.opts.editable) != null ? _ref4 : false;
      this.load();
    }
    Chart.prototype._load_occupancy = function() {
      return $.when($D.parties.init()).then(__bind(function() {
        $D.parties.live('rowAdd', __bind(function(e, row) {
          var table;
          if (row.occupancy) {
            if (row.occupancy.chart === this.opts.key) {
              table = this.get_sprite(row.occupancy.table);
              if (table != null) {
                table.occupy(row);
              } else {
                $.log("No table");
              }
            }
          }
          return true;
        }, this));
        return $D.parties.bind('rowRemove', __bind(function(e, row, prev_row) {
          var table;
          if (prev_row.occupancy) {
            if (prev_row.occupancy.chart === this.opts.key) {
              table = this.get_sprite(prev_row.occupancy.table);
              if (table != null) {
                table.occupy(null);
              }
            }
          }
          return true;
        }, this));
      }, this));
    };
    Chart.prototype.get_sprite = function(key) {
      var sprite, _i, _len, _ref2;
      _ref2 = this.sprites;
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        sprite = _ref2[_i];
        if (key === sprite.opts.key) {
          return sprite;
        }
      }
      return null;
    };
    Chart.prototype.load = function() {
      return $.when($D.charts.init()).then(__bind(function() {
        return $D.charts.get(this.opts.key, __bind(function(row) {
          if (row) {
            this.unpack(row.sprites);
          }
          return this._load_occupancy();
        }, this));
      }, this));
    };
    Chart.prototype.save = function() {
      var obj;
      obj = $.extend({}, this.opts, {
        sprites: this.pack()
      });
      return $.when($D.charts.init()).then(__bind(function() {
        return $D.charts.add(obj);
      }, this));
    };
    Chart.prototype.set_editable = function(editable) {
      var sprite, _i, _len, _ref2, _results;
      if (editable == null) {
        editable = true;
      }
      if (this.editable === editable) {
        return;
      }
      this.editable = editable;
      _ref2 = this.sprites;
      _results = [];
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        sprite = _ref2[_i];
        _results.push(this.editable ? ($TC.draggable_sprite(sprite, this), this.trigger('unlocked')) : ($$(sprite).draggable_sprite.destroy(), this.trigger('locked')));
      }
      return _results;
    };
    Chart.prototype.add = function(sprite, type) {
      var props;
      if (type != null) {
        props = {
          opts: sprite,
          type: type
        };
        sprite = this.create(props);
      }
      this.sprites.push(sprite);
      if (this.editable) {
        $TC.draggable_sprite(sprite, this);
      }
      this.trigger('add', [sprite]);
      return sprite;
    };
    Chart.prototype.live = function(evt, func) {
      var sprite, _i, _len, _ref2;
      if (evt === 'add') {
        _ref2 = this.sprites;
        for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
          sprite = _ref2[_i];
          func(false, sprite);
        }
      }
      return this.bind(evt, func);
    };
    Chart.prototype.clear = function() {
      var sprite, _i, _len, _ref2;
      _ref2 = this.sprites;
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        sprite = _ref2[_i];
        sprite.destroy();
      }
      return this.sprites = [];
    };
    Chart.prototype._find = function(sprite) {
      var i, s, _len, _ref2;
      _ref2 = this.sprites;
      for (i = 0, _len = _ref2.length; i < _len; i++) {
        s = _ref2[i];
        if (s === sprite) {
          return i;
        }
      }
      throw "Sprite not found";
    };
    Chart.prototype.remove = function(sprite) {
      var index;
      index = this._find(sprite);
      sprite.destroy();
      this.sprites.removeAt(index);
      this.draw();
      this.save();
      return this.trigger('remove', [sprite, this]);
    };
    Chart.prototype.change_type = function(sprite, dest_type) {
      var index, n_spr, props;
      index = this._find(sprite);
      props = sprite.package();
      props.type = dest_type;
      n_spr = this.create(props);
      sprite.destroy();
      this.sprites[index] = n_spr;
      this.draw();
      return n_spr;
    };
    Chart.prototype.draw = function() {
      var sprite, _i, _len, _ref2, _results;
      _ref2 = this.sprites;
      _results = [];
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        sprite = _ref2[_i];
        _results.push(sprite.draw(this.cont));
      }
      return _results;
    };
    Chart.prototype.pack = function() {
      var obj, out, sprite, _i, _len, _ref2;
      out = [];
      _ref2 = this.sprites;
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        sprite = _ref2[_i];
        obj = sprite.package();
        if (!obj.type) {
          obj.type = sprite.__proto__.constructor.name;
        }
        out.push(obj);
      }
      return out;
    };
    Chart.prototype.create = function(entry) {
      var cls, sprite;
      cls = $TC[entry.type];
      sprite = new cls(entry.opts);
      return sprite;
    };
    Chart.prototype.unpack = function(data) {
      var entry, sprite, _i, _len;
      this.clear();
      for (_i = 0, _len = data.length; _i < _len; _i++) {
        entry = data[_i];
        sprite = this.create(entry);
        this.add(sprite);
      }
      return this.draw();
    };
    return Chart;
  })();
}).call(this);
