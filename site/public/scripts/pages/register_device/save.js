(function() {
  $(function() {
    var $page;
    $page = $('#register_device');
    return $('a[href=#register]', $page).bind('vclick', function(e) {
      e.preventDefault();
      e.stopPropagation();
      return $IO.register_device({
        auth: {
          username: $page.filter('input[name=username]').val(),
          password: $page.filter('input[name=password]').val()
        },
        nickname: $page.filter('input[name=nickname]').val()
      }, {
        success: function() {
          return $page.dialog('close');
        }
      });
    });
  });
}).call(this);
