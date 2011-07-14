$ ->
  $('#add-party a[href=#add]').live 'vclick', (e) ->
    do e.preventDefault
    do e.stopPropagation

    dia = $ '#add-party'

    vals =
      name: $('[name=name]', dia).val()
      size: $('[name=party_size]', dia).val()
      phone: $('[name=phone_number]', dia).val()
      quoted_wait: $('[name=wait_time]', dia).val()
      seating_pref: $('[name=seating_preference]', dia).val()
      called_ahead: $('[name=called_ahead]', dia).val()
      alert_method: $('[name=alert_method]', dia).val()
      notes: $('[name=notes]', dia).val()

    $$('#queue-list').queue.add(vals)

    $.log 'close'
    dia.dialog 'close'
    $.log 'ed'

    false

  last_title = false
  add_el = false
  cancel_el = false

  show_fake_page = (self) ->
    # Add Dummy List Element
    add_el = $ '<li></li>'
    link = $ '<a></a>'
    add_el.append link

    link.addClass "list-action"
    link.text "Check-In Without Queue"
  
    $('#queue-list').prepend add_el
    $('#queue-list').listview 'refresh'

    # Hide Add Button
    cancel_el = $ '<a></a>'
    cancel_el.attr('href', '#queue')
    cancel_el.addClass 'ui-btn-left'

    $('a[href=#add-party]')
      .hide()
      .before cancel_el

    cancel_el.buttonMarkup
      icon: 'arrow-l'
      iconpos: 'notext'

    cancel_el.click ->
      hide_fake_page self

    do $(self).hide

    last_title = $('.ui-title:visible').text()
    $('.ui-title:visible').text 'Choose a Party'

  hide_fake_page = (self) ->
    do $('a[href=#add-party]').show
    do cancel_el.remove
    do add_el.remove
    do $(self).show

    $('.ui-title:visible').text last_title
    last_title = false

  $('a[href=#check-in]').click (e) ->
    do e.preventDefault

    if last_title
      hide_fake_page this
    show_fake_page this
    
    false
  

  $('[data-role=dialog], [data-role=page]').live 'pagecreate', ->
    mousedown = false
    timeout = false

    wait_time = 600
    def_speed = 400
    speed_scale = 7.0

    ranges = $('input[data-type=range]', this)

    ranges.change ->
      if this.getAttribute('step')
        val = parseInt this.value
        step = parseInt this.getAttribute 'step'

        this.value = val - (val % step)

    ranges.change ->
      if mousedown and not timeout and this.value == this.getAttribute('max')
        # To keep normal sliding smooth, we check if the val == the max
        # before we bother building the jQuery obj

        self = $(this)
        speed = def_speed
        step = parseInt(self.attr('step') || '1')
        
        set_timeout = (s=speed) ->
          timeout = setTimeout(up, s)

        up = ->
          if mousedown and self.val() == self.attr('max')
            # We have to test that val == max again, so they can slide back down
            
            speed -= speed / speed_scale
            speed = Math.max(speed, 10)
            do set_timeout
            
            self.attr('max', parseInt(self.attr('max')) + step)
            self.val(self.attr('max'))
            self.slider('refresh')
          else
            timeout = false

        set_timeout wait_time

    $('.ui-slider-handle', this).bind 'mousedown vmousedown',  ->
      mousedown = true
    .bind 'mouseup vmouseup', ->
      # vmouseup doesn't fire on the body
      mousedown = false
      return true

    $(document).bind 'mouseup vmouseup', ->
      mousedown = false

  $('#add-party').live 'pagecreate', ->
    self = this

    $('[name=phone_number]', this).guest_search
      field: 'phone'

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

    $phone = $('[name=phone_number]')
    activate_phone_opts.call $phone[0]
    $phone.bind 'keyup change', activate_phone_opts


    # Show extra alert method fields

    $alert_method.change ->
      val = this.value

      do $("[data-bound-value]", self).hide
      do $("[data-bound-value=#{val}]", self).show


