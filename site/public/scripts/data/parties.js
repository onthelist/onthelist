(function() {
  var Parties, Party;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  Party = (function() {
    __extends(Party, $D._DataRow);
    function Party() {
      Party.__super__.constructor.apply(this, arguments);
    }
    Party.prototype.add_status = function(name) {
      var prev, _ref;
      if ((_ref = this.status) == null) {
        this.status = [];
      }
      prev = this.status.clone();
      if (['waiting', 'seated', 'left'].has(name)) {
        this.status = this.status.subtract(['waiting', 'seated', 'left']);
      }
      if (this.status.has(name)) {
        return;
      }
      this.status.push(name);
      return this.trigger('status:change', [this.status, prev]);
    };
    Party.prototype.remove_status = function(name) {
      var prev, _ref;
      if ((_ref = this.status) == null) {
        this.status = [];
      }
      prev = this.status.clone();
      if (!this.status.has(name)) {
        return;
      }
      this.status.remove(name);
      return this.trigger('status:change', [this.status, prev]);
    };
    return Party;
  })();
  Parties = (function() {
    __extends(Parties, $D._DataLoader);
    function Parties() {
      Parties.__super__.constructor.apply(this, arguments);
    }
    Parties.prototype.name = 'parties';
    Parties.prototype.model = Party;
    Parties.prototype.add = function(vals) {
      var _base, _convert_times, _ref, _ref2;
      if (vals == null) {
        vals = {};
      }
      if ((_ref = vals.times) == null) {
        vals.times = {};
      }
      if ((_ref2 = (_base = vals.times).add) == null) {
        _base.add = new Date;
      }
      _convert_times = function(times) {
        var name, time, _results;
        _results = [];
        for (name in times) {
          if (!__hasProp.call(times, name)) continue;
          time = times[name];
          _results.push(Object.isDate(time) ? times[name] = time.toISOString() : Object.isObject(time || Object.isArray(time)) ? _convert_times(time) : void 0);
        }
        return _results;
      };
      _convert_times(vals.times);
      return Parties.__super__.add.call(this, vals);
    };
    return Parties;
  })();
  $D.parties = new Parties;
  $.when($D.parties.init()).then(function() {
    $D.parties.ds.each(function(row) {
      var _ref;
      if (!((_ref = row.times) != null ? _ref.add : void 0) || Date.get_elapsed(row.times.add) > 60 * 2) {
        return $D.parties.ds.remove(row);
      }
    });
    return $D.parties.ds.all(function(rows) {
      var fnames, len, lnames, name, note, notes, size, time, _results;
      len = rows.length;
      _results = [];
      while (len++ < 12) {
        fnames = ['John', 'Jane', 'Zack', 'Marshall', 'Dick'];
        lnames = ['Smith', 'Bloom', 'Wright', 'Miller', 'Lombardi'];
        name = fnames[Math.floor(Math.random() * 5)] + ' ' + lnames[Math.floor(Math.random() * 5)];
        size = Math.ceil(Math.random() * 12);
        time = Math.floor(Math.random() * 90);
        notes = ['Requests a quiet table', 'Drink: Martini extra olives', ''];
        note = notes[Math.floor(Math.random() * 3)];
        _results.push($D.parties.add({
          key: $D.parties.ds.uuid(),
          name: name,
          size: size,
          times: {
            add: (new Date).add(-time).minutes()
          },
          phone: '2482298031',
          quoted_wait: 60,
          alert_method: 'sms',
          status: ['waiting'],
          notes: note
        }));
      }
      return _results;
    });
  });
}).call(this);
