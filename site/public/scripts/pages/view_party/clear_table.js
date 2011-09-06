(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  $(function() {
    return $('#view-party').bind('pagecreate', function() {
      return $('[name=clear_table]', this).bind('vclick', __bind(function() {
        var data;
        data = $$(this).data;
        $(this).dialog('close');
        $QUEUE.check_out(data.key);
        return false;
      }, this));
    });
  });
}).call(this);
