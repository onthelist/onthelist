(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  $(function() {
    return $('#view-party').bind('pagecreate', function() {
      return $('[name=check_in]', this).bind('vclick', __bind(function(e) {
        var data;
        data = $$(this).data;
        $(this).dialog('close');
        $QUEUE.check_in(data.key);
        return false;
      }, this));
    });
  });
}).call(this);
