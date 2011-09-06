(function() {
  var _ref;
  if ((_ref = window.$M) == null) {
    window.$M = {};
  }
  $M.send_sms = function(to, body, opts) {
    var data;
    if (opts == null) {
      opts = {};
    }
    data = $IO.build_req({
      to: to,
      body: body
    });
    $.extend(opts, {
      type: 'POST',
      url: '/messaging/send/sms',
      data: data
    });
    return $IO.make_req(opts);
  };
  $M.make_call = function(to, body, opts) {
    var data;
    if (opts == null) {
      opts = {};
    }
    data = $IO.build_req({
      to: to,
      body: body
    });
    $.extend(opts, {
      type: 'POST',
      url: '/messaging/send/phone',
      data: data
    });
    return $IO.make_req(opts);
  };
}).call(this);
