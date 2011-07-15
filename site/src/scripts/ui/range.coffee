$ ->
  $('[data-role=dialog], [data-role=page]').live 'pagecreate', ->
    # Make ranges auto increase their range while held in the max pos.
    
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

