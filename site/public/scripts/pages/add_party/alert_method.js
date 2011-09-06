(function() {
  $(function() {
    return $('#add-party').live('pagecreate', function() {
      var $alert_method, $call_radio, $phone, $sms_radio, activate_phone_opts, phone_disabled, self;
      self = this;
      phone_disabled = false;
      $alert_method = $('[name=alert_method]', this);
      $sms_radio = $alert_method.filter('[value=sms]');
      $call_radio = $alert_method.filter('[value=call]');
      activate_phone_opts = function() {
        var empty;
        empty = this.value === '';
        if (empty === phone_disabled) {
          return true;
        }
        phone_disabled = empty;
        $sms_radio.attr('disabled', phone_disabled);
        $call_radio.attr('disabled', phone_disabled);
        if (!phone_disabled && !$alert_method.filter(':checked').length) {
          $sms_radio.attr('checked', true);
        }
        if (phone_disabled && ($sms_radio.attr('checked') || $call_radio.attr('checked'))) {
          $sms_radio.attr('checked', false);
          $call_radio.attr('checked', false);
        }
        $sms_radio.checkboxradio('refresh');
        return $call_radio.checkboxradio('refresh');
      };
      $phone = $('[name=phone]');
      activate_phone_opts.call($phone[0]);
      $phone.bind('keyup change refresh', activate_phone_opts);
      return $alert_method.change(function() {
        var val;
        val = this.value;
        $("[data-bound-value]", self).hide();
        return $("[data-bound-value=" + val + "]", self).show();
      });
    });
  });
}).call(this);
