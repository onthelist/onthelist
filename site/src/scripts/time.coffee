$.fn.time = (opts, args...) ->
  class TimeDisplay
    constructor: (@elem, @opts) ->
      @format = @opts.format ? 'elapsed'

      setInterval(=>
        do this.update
      , 60000)

      do this.update

    toggle_format: ->
      @format = if @format is 'elapsed' then 'remaining' else 'elapsed'

      @elem.removeClass 'overtime'

      do this.update

    update: ->
      @elapsed = Date.get_elapsed @elem.attr('datetime')
      @elem.attr 'data-minutes', @elapsed

      @target = parseInt @elem.attr 'data-target'
      if @target == NaN
        @target = null

      do this["_update_#{@format}"]

    _update_elapsed: ->
      @elem.text Date.format_elapsed @elapsed

    _update_remaining: ->
      if not @target?
        @elem.text ''
        return

      rem = @target - @elapsed
    
      str = ''
      if rem < 0
        @elem.addClass 'overtime'
      else
        str += '+'
        @elem.removeClass 'overtime'

      str += rem + ' min'

      @elem.text str

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

     
      # Outline
      cxt.arc rad, rad, rad - .5, 0, Math.PI * 2, false
      cxt.strokeStyle = '#BBB'
      cxt.lineWidth = 1
      do cxt.stroke

      # Wedge
      do cxt.beginPath
      cxt.moveTo rad, rad
      cxt.lineTo rad, 0
      cxt.arc rad, rad, rad, st_ang, end_ang, false
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
