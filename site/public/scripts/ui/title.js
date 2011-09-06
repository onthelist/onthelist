(function() {
  $(function() {
    return $('[data-role=page]').bind('pageshow', function() {
      var $head;
      $head = $('h1[data-key=page_title]', this);
      if ($D.device.get('registered')) {
        $head.text($D.device.get('display_organization'));
      } else {
        $head.html('Local Mode - <a href="#register_device">Register Device</a>');
      }
      return true;
    });
  });
}).call(this);
