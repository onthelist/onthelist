(function() {
  Backbone.sync = function(method, model, opts) {
    return $.log(method, model, opts);
  };
}).call(this);
