(function() {
  $(function() {
    if ($S.look.theme === 'dark') {
      $('body').addClass('dark-theme');
    }
    return $('[data-role=header], [data-role=header] h1').bind('swipeleft swiperight', function(e) {
      $('body').toggleClass('dark-theme');
      $S.look.theme = ($('body').hasClass('dark-theme') ? 'dark' : 'light');
      return $S.save();
    });
  });
}).call(this);
