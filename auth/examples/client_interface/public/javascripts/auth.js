(function() {
  var err, show;
  show = function(data) {
    return $('body').append($('<div></div>').text(JSON.stringify(data)));
  };
  err = function(req) {
    return $('body').append($('<div></div>').css('color', 'red').text(req.responseText));
  };
  $(function() {
    $('#create-account').submit(function(evt) {
      var password, username;
      evt.preventDefault();
      username = $('input[name=username]', this).val();
      password = $('input[name=password]', this).val();
      return $.ajax({
        url: '/account',
        data: {
          username: username,
          password: password
        },
        type: 'POST',
        error: err,
        success: show
      });
    });
    $('#login').submit(function(evt) {
      var password, username;
      evt.preventDefault();
      username = $('input[name=username]', this).val();
      password = $('input[name=password]', this).val();
      return $.ajax({
        url: '/_session',
        data: {
          username: username,
          password: password
        },
        type: 'POST',
        error: err,
        success: show
      });
    });
    $('a[href=#logout]').click(function(evt) {
      evt.preventDefault();
      return $.ajax({
        url: '/_session',
        type: 'DELETE',
        error: err,
        success: show
      });
    });
    return $('a[href=#get_user]').click(function(evt) {
      evt.preventDefault();
      return $.ajax({
        url: '/_session/user',
        error: err,
        success: show
      });
    });
  });
}).call(this);
