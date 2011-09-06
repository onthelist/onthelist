(function() {
  $(function() {
    return $('#view-party').bind('pagecreate', function() {
      var page;
      page = this;
      return $('[name=alert_party]', this).bind('vclick', function(e) {
        var data;
        data = $$(page).data;
        $IO.alert(data);
        return false;
      });
    });
  });
}).call(this);
