(function() {
  var _ref;
  var __slice = Array.prototype.slice;
  if ((_ref = window.$U) == null) {
    window.$U = {};
  }
  $U.Evented = (function() {
    function Evented() {
      this._evt = $({});
    }
    Evented.prototype.trigger = function() {
      var args, _ref2;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return (_ref2 = this._evt).trigger.apply(_ref2, args);
    };
    Evented.prototype.live = function(evt, func) {
      return this._evt.bind(evt, func);
    };
    Evented.prototype.bind = function() {
      var args, _ref2;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return (_ref2 = this._evt).bind.apply(_ref2, args);
    };
    Evented.prototype.unbind = function() {
      var args, _ref2;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return (_ref2 = this._evt).unbind.apply(_ref2, args);
    };
    return Evented;
  })();
}).call(this);
