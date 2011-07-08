$.fn.time = (opts, args...) ->
  class TimeDisplay
    constructor: (@elem, @opts) ->
      @format = @opts.format ? 'elapsed'

      setInterval(=>
        do this.update
      , 60000)
    
    toggle_format: ->
      @format = if @format is 'elapsed' then 'remaining' else 'elapsed'

      @elem.removeClass 'overtime'

      do this.update

    update: ->
      @elapsed = Date.get_elapsed @elem.attr('datetime')
      @elem.attr 'data-minutes', @elapsed

      @target = @elem.attr 'data-target'
      if @target?
        @target = parseInt @target

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

  if typeof opts == 'string'
    this.each (i, elem) ->
      time_disp = $$(elem).time_disp
      time_disp[opts](args...)

  else
    def_opts =
      'type': 'string'

    opts = $.extend {}, def_opts, opts

    time_disp = $$(this).time_disp = new TimeDisplay(this, opts)
