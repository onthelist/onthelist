(function() {
  var _base, _ref;
  if ((_ref = (_base = window.$D).settings) == null) {
    _base.settings = {};
  }
  $D.settings["default"] = {
    look: {
      theme: 'light'
    },
    queue: {
      sort: 'remaining',
      group: 'lname',
      time_view: 'remaining'
    }
  };
}).call(this);
