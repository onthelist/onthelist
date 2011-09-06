(function() {
  var codes;
  window.$CTRL_KEYS = $({});
  codes = {
    16: 'shift',
    17: 'ctrl',
    18: 'alt'
  };
  $(document).keydown(function(e) {
    var name;
    name = codes[e.keyCode];
    if (name) {
      $CTRL_KEYS[name] = true;
      return $CTRL_KEYS.trigger("" + name + "down");
    }
  });
  $(document).keyup(function(e) {
    var name;
    name = codes[e.keyCode];
    if (name) {
      $CTRL_KEYS[name] = false;
      return $CTRL_KEYS.trigger("" + name + "up");
    }
  });
}).call(this);
