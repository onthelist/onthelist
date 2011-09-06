(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  $(function() {
    var created;
    created = false;
    return $('#add-party').bind('pageshow', function() {
      if (created) {
        return;
      }
      created = true;
      return $('[name=phone]', this).guest_search({
        field: 'phone'
      }).bind('fill', __bind(function(e, row) {
        $('[name=name]', this).val(row.name);
        $('[name=notes]', this).val(row.notes);
        $('[name=alert_method]', this).val(row.alert_method);
        $('[name=seating_preference]', this).val(row.seating_preference);
        return $('[name=size]', this).focus();
      }, this));
    });
  });
}).call(this);
