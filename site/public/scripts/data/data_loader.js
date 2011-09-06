(function() {
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  $D._DataLoader = (function() {
    __extends(_DataLoader, $U.Evented);
    function _DataLoader() {
      _DataLoader.__super__.constructor.apply(this, arguments);
      this.ready = $.Deferred();
      this.initing = false;
      this.cache = {};
    }
    _DataLoader.prototype.init = function() {
      var opts;
      if (!this.initing && !(this.ds != null)) {
        this.initing = true;
        opts = {
          name: this.name,
          record: this.name
        };
        new Lawnchair(opts, __bind(function(ds) {
          this.initing = false;
          this.ds = ds;
          this.ready.resolve(this);
          return this.ds.each(__bind(function(row) {
            return this.register_row(this._wrap_row(row));
          }, this));
        }, this));
      }
      return this.ready.promise();
    };
    _DataLoader.prototype.remove = function(row, prev_row) {
      if (typeof row === 'string') {
        this.ds.get(row, __bind(function(data) {
          return this.remove(data);
        }, this));
        return;
      }
      return this.ds.remove(row, __bind(function() {
        return this.trigger('rowRemove', [row, prev_row != null ? prev_row : row]);
      }, this));
    };
    _DataLoader.prototype.add = function(vals) {
      if (vals == null) {
        vals = {};
      }
      return this.ds.save(vals, __bind(function(resp) {
        return this.register_row(this._wrap_row(resp));
      }, this));
    };
    _DataLoader.prototype.update = function(vals) {
      return this.ds.save(vals);
    };
    _DataLoader.prototype.save = function(vals) {
      if (vals.save != null) {
        return vals.save();
      } else {
        return this.get(vals.key, __bind(function(data) {
          if (data) {
            this.remove(vals);
          }
          return this.add(vals);
        }, this));
      }
    };
    _DataLoader.prototype.get = function(id, func) {
      return this.ds.get(id, __bind(function(data) {
        return func(this._wrap_row(data));
      }, this));
    };
    _DataLoader.prototype.find = function(filter, res) {
      var out;
      out = [];
      return this.ds.all(__bind(function(rows) {
        var row;
        return res((function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = rows.length; _i < _len; _i++) {
            row = rows[_i];
            if (filter(row)) {
              _results.push(this._wrap_row(row));
            }
          }
          return _results;
        }).call(this));
      }, this));
    };
    _DataLoader.prototype.register_row = function(row) {
      return this.trigger('rowAdd', row);
    };
    _DataLoader.prototype.live = function(evt, func) {
      if ((this.ds != null) && evt.indexOf('row' === 0)) {
        this.ds.each(__bind(function(row) {
          return func(false, this._wrap_row(row));
        }, this));
      }
      return this.bind(evt, func);
    };
    _DataLoader.prototype._wrap_row = function(row) {
      if (!this.model) {
        return row;
      }
      if (row.key in this.cache) {
        this.cache[row.key]._extend(row);
      } else {
        this.cache[row.key] = new this.model(row, this);
      }
      return this.cache[row.key];
    };
    return _DataLoader;
  })();
  $D._DataRow = (function() {
    __extends(_DataRow, $U.Evented);
    function _DataRow(data, _coll) {
      this._coll = _coll;
      _DataRow.__super__.constructor.apply(this, arguments);
      this._extend(data);
    }
    _DataRow.prototype._extend = function(data) {
      return $.extend(this, data);
    };
    _DataRow.prototype.fetch = function(cb) {
      return this._coll.get(this.key, __bind(function(data) {
        this._extend(data);
        this._prev_data = data;
        return cb && cb(this);
      }, this));
    };
    _DataRow.prototype.save = function(replace) {
      var data, name, val;
      if (replace == null) {
        replace = true;
      }
      data = {};
      for (name in this) {
        if (!__hasProp.call(this, name)) continue;
        val = this[name];
        if (name.substring(0, 1) !== '_' && typeof val !== 'function') {
          data[name] = val;
        }
      }
      if (replace) {
        this._coll.remove(data, this._prev_data);
        this._coll.add(data, this._prev_data);
      } else {
        this._coll.update(data, this._prev_data);
      }
      return this._prev_data = data;
    };
    return _DataRow;
  })();
}).call(this);
