$ ->
  $('#add-party').live 'pagecreate', ->
    self = this

    # Disable sms + call alert methods if there is no phone #

    phone_disabled = false
    $alert_method = $('[name=alert_method]', this)
    $sms_radio = $alert_method.filter('[value=sms]')
    $call_radio = $alert_method.filter('[value=call]')

    activate_phone_opts = ->
      empty = (this.value == '')

      if empty == phone_disabled
        return true

      phone_disabled = empty

      $sms_radio.attr('disabled', phone_disabled)
      $call_radio.attr('disabled', phone_disabled)

      if not phone_disabled and not $alert_method.filter(':checked').length
        $sms_radio.attr('checked', true)

      if phone_disabled and ($sms_radio.attr('checked') or $call_radio.attr('checked'))
        $sms_radio.attr('checked', false)
        $call_radio.attr('checked', false)

      $sms_radio.checkboxradio 'refresh'
      $call_radio.checkboxradio 'refresh'

    $phone = $('[name=phone]')
    activate_phone_opts.call $phone[0]
    $phone.bind 'keyup change', activate_phone_opts


    # Show extra alert method fields

    $alert_method.change ->
      val = this.value

      do $("[data-bound-value]", self).hide
      do $("[data-bound-value=#{val}]", self).show

