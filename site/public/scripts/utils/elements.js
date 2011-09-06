(function() {
  window.$$ = function(node) {
    var data;
    data = $(node).jqmData("$$");
    if (!data) {
      data = {};
      $(node).jqmData("$$", data);
    }
    return data;
  };
}).call(this);
