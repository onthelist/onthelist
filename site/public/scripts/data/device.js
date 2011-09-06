(function() {
  var Device, _ref;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  window.$ID = (_ref = localStorage.DEVICE_ID) != null ? _ref : Math.floor(Math.random() * 100000000000000);
  localStorage.DEVICE_ID = $ID;
  Device = (function() {
    __extends(Device, Backbone.Model);
    function Device() {
      Device.__super__.constructor.apply(this, arguments);
    }
    Device.prototype.localStorage = new Store('device');
    Device.prototype.id = $ID;
    return Device;
  })();
  $D.device = new Device;
  $D.device.fetch();
  if (!$D.device.get('created')) {
    $.log('unregistered device');
    $D.device.set({
      create_time: new Date,
      settings: {},
      registered: false,
      created: true
    });
    $D.device.attributes.settings = $.extend(true, {}, $D.settings["default"], $D.device.attributes.settings);
    $D.device.save();
  }
  $IO.fetch_device();
  window.$S = $.extend({}, $D.device.get('settings'), {
    save: function() {
      return $D.device.save();
    }
  });
}).call(this);
