(function() {
  var REMOTE_LOGGING;
  var __slice = Array.prototype.slice;
  REMOTE_LOGGING = false;
  $.log = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    if (window && window.console && window.console.log) {
      console.log.apply(console, args);
    }
    if (REMOTE_LOGGING) {
      try {
        return $.ajax({
          url: '/log/console',
          type: 'POST',
          data: {
            args: args
          }
        });
      } catch (e) {
        return false;
      }
    }
  };
}).call(this);
