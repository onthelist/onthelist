(function() {
  var _ref;
  if ((_ref = window.$IO) == null) {
    window.$IO = {};
  }
  $IO.register_device = function(props, opts) {
    var data;
    if (props == null) {
      props = {};
    }
    if (opts == null) {
      opts = {};
    }
    props.device = $D.device.attributes;
    data = $IO.build_req(props);
    opts.beforeSuccess = function(data) {
      $D.device.set(data.device);
      $D.device.save();
      return data;
    };
    $.extend(opts, {
      url: '/device/register',
      type: 'POST',
      data: data
    });
    return $IO.make_req(opts);
  };
  $IO.fetch_device = function(opts) {
    var data;
    if (opts == null) {
      opts = {};
    }
    data = $IO.build_req();
    opts.beforeSuccess = function(data) {
      $D.device.set(data.device);
      $D.device.save();
      return data;
    };
    opts.beforeError = function(data, status, err_text) {
      if (err_text === 'Not Found') {
        $D.device.attributes.registered = false;
        $D.device.save();
      }
      return [data, status, err_text];
    };
    $.extend(opts, {
      url: '/device/',
      data: data
    });
    return $IO.make_req(opts);
  };
}).call(this);
