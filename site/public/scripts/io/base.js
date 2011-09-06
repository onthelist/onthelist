(function() {
  var _ref;
  if ((_ref = window.$IO) == null) {
    window.$IO = {};
  }
  $IO.build_req = function(props) {
    if (props == null) {
      props = {};
    }
    $.extend(props, {
      device_id: $ID
    });
    return props;
  };
  $IO.make_req = function(opts) {
    var error, success;
    if (opts.beforeSuccess != null) {
      success = opts.success;
      opts.success = function(data) {
        var ret;
        if (data && data.ok) {
          ret = opts.beforeSuccess(data);
          return success && success(ret);
        } else {
          return opts.error && opts.error(data);
        }
      };
    }
    if (opts.beforeError != null) {
      error = opts.error;
      opts.error = function(data, status, err_text) {
        var ret;
        ret = opts.beforeError(data, status, err_text);
        return error && error.apply(null, ret);
      };
    }
    if (opts.type === 'POST') {
      opts.contentType = 'application/json';
      if (typeof opts.data !== 'string') {
        opts.data = JSON.stringify(opts.data);
      }
    }
    return $.ajax(opts);
  };
}).call(this);
