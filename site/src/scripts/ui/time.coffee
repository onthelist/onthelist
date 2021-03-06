# Display a time as elapsed minutes, remaining minutes or a graphical timer.
$.fn.time = (opts, args...) ->
  if not this.length
    return

  class TimeDisplay
    constructor: (@elem, @opts) ->
      @format = @opts.format ? $(@elem).attr('data-format') ? 'elapsed'

      do @set_interval

      do @update

    set_interval: (time=60000) ->
      if @update_freq == time
        return

      @update_freq = time

      if @interval?
        clearInterval @interval

      @interval = setInterval(=>
        do @update
      , time)

    toggle_format: ->
      @format = if @format is 'elapsed' then 'remaining' else 'elapsed'

      @elem.removeClass 'overtime'

      do this.update

    update: ->
      @elapsed = Date.get_elapsed @elem.attr('datetime')
      @elem.attr 'data-minutes', @elapsed

      @target = parseFloat @elem.attr 'data-target'
      if @target == NaN
        @target = null

      do this["_update_#{@format}"]

    _update_elapsed: ->
      @elem.text $F.date.format_elapsed @elapsed

    _update_remaining: ->
      if not @target?
        @elem.text ''
        return

      rem = @target - @elapsed
   
      if rem < 0
        @elem.addClass 'overtime'
      else
        @elem.removeClass 'overtime'

      str = $F.date.format_remaining rem, @opts.sign ? true, @opts.sec ? false

      @elem.text str

      if 0 < rem < 1
        @set_interval 200
      else
        @set_interval 60000

    _update_icon: ->
      if not @target?
        return

      if not @elem.find('canvas').length
        @elem.addClass 'icon'

        canvas_jq = $ '<canvas></canvas>'
        canvas_jq.addClass 'icon-canvas'
        canvas_jq.attr 'width', '20'
        canvas_jq.attr 'height', '20'

        @elem.append canvas_jq

        canvas = canvas_jq[0]
      else
        canvas = @elem.find('canvas')[0]

      cxt = canvas.getContext "2d"
      
      cxt.clearRect 0, 0, canvas.width, canvas.height

      rad = canvas.width / 2

      per = Math.abs(@target - @elapsed) / @target

      if @elapsed <= @target
        # Flip the orientation to fill when we're before the target
        # and restart after we've passed it
        per = 1 - per
      
      st_ang = -Math.PI * .5
      end_ang = st_ang + per * Math.PI * 2

     
      # Background Circle
      do cxt.beginPath
      cxt.arc rad, rad, rad - .5, 0, Math.PI * 2, false
      do cxt.closePath
      cxt.fillStyle = '#F0F0F0'
      do cxt.fill

      # Wedge
      do cxt.beginPath
      cxt.moveTo rad, rad
      cxt.lineTo rad, 0
      cxt.arc rad, rad, rad - .5 - 2, st_ang, end_ang, false
      do cxt.closePath

      cxt.fillStyle = if @target <= @elapsed then "#D44" else "#666"
      do cxt.fill

  if typeof opts == 'string'
    this.each (i, elem) ->
      time_disp = $$(elem).time_disp
      time_disp[opts](args...)

  else
    def_opts =
      'type': 'string'

    opts = $.extend {}, def_opts, opts

    time_disp = $$(this).time_disp = new TimeDisplay(this, opts)
