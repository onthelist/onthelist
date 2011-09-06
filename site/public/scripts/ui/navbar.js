(function() {
  $('[data-role=page]').live('pagebeforeshow', function() {
    var hash;
    hash = '#' + this.getAttribute('id');
    return $('[data-role=navbar] a').removeClass('ui-btn-active').filter('[href=' + hash + ']').addClass('ui-btn-active ui-state-persist');
  });
}).call(this);
