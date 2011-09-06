(function() {
  $(function() {
    return $('#add-party').bind('pagecreate', function() {
      var $name, $phone, phone_first, swap;
      $name = $('[name=name]', this);
      $phone = $('[name=phone]', this);
      phone_first = true;
      swap = function() {
        var $name_cont, $phone_cont, n_val, p_val;
        $name_cont = $name.parents('.ui-field-contain').first();
        $phone_cont = $phone.parents('.ui-field-contain').first();
        p_val = $phone.val();
        n_val = $name.val();
        $phone.val(n_val);
        $name.val(p_val);
        $name_cont.detach();
        if (phone_first) {
          $name_cont.insertBefore($phone_cont);
          $name.focus();
        } else {
          $name_cont.insertAfter($phone_cont);
          $phone.focus();
        }
        return phone_first = !phone_first;
      };
      $phone.keyup(function(e) {
        var c, code, val;
        val = $phone.val();
        c = val.charCodeAt(val.length - 1);
        if (!((97 <= c && c <= 122) || (65 <= c && c <= 90) || (48 <= c && c <= 57))) {
          $phone.val(val.substring(0, val.length - 2));
          return false;
        }
        if (val.length !== 1) {
          return;
        }
        code = val.charCodeAt(0);
        if ((97 <= code && code <= 122) || (65 <= code && code <= 90)) {
          return swap();
        }
      });
      return $(this).bind('pageshow', function() {
        if (!phone_first) {
          return swap();
        }
      });
    });
  });
}).call(this);
