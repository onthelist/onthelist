class TimeList
  constructor: (@elem) ->
    $$(@elem).time_list = this

    do this.add_sections

  add_sections: ->

  refresh: ->
    if @elem.jqmData 'listview'
      @elem.listview 'refresh'

class ElapsedTimeList extends TimeList
  constructor: (@elem) ->
    super @elem

    self = this

    setInterval(->
      do self.update
    , 60000)

  add_sections: ->
    @time_blocks = [10, 30, 60, '+']
    @sections = {}

    for i, block of @time_blocks
      if i == '0'
        start = 0
      else
        start = @time_blocks[i-1] + 1
      
      end = block

      li = @sections[i] = $('<li></li>')
      li.attr('data-role', 'list-divider')
      li.attr('data-theme', 'a')
      li.attr('data-start', start)

      text = ''
      if end != '+'
        text += start + ' - ' + end
      else
        text += 'More Than ' + start
      text += ' mins'

      li.text text

      @elem.append li

    do this.refresh

  insert: (elem, elapsed=null) ->
    if not elapsed
      # We can pass in elapsed time to avoid having to parse it twice
      elapsed = parseInt $('time', elem).attr 'data-minutes'

    last = null
    @elem.children('li').each (i, el) ->
      if not last
        # Just in case we have a negative elapsed
        last = el

      if el.getAttribute('data-place') == 'false'
        # If it's a divider, we also won't place beyond it:
        return (el.getAttribute('data-role') != 'list-divider')

      if el.getAttribute('data-role') == 'list-divider'
        start = parseInt el.getAttribute 'data-start'
      else
        start = parseInt $('time', el).attr 'data-minutes'

      if elapsed < start
        return false

      last = el

    $(last).after elem

    do this.refresh

  _update_time_display: (elem, elapsed) ->
    elem.innerHTML = Date.format_elapsed elapsed

  update: ->
    self = this

    @elem.find('time').each (i, elem) ->
      elapsed = Date.get_elapsed elem.getAttribute('datetime')
      elem.setAttribute 'data-minutes', elapsed

      self._update_time_display elem, elapsed

    @elem.children('li[data-role=list-divider]').each (i, elem) ->
      elem = $ elem

      start = parseInt elem.attr 'data-start'
      if start == NaN
        return

      last = null
      elem.prevAll('li').each (j, el) ->
        time = $('time', el)
        if not time
          return

        if parseInt(time.attr 'data-minutes') >= start
          last = el
        else
          return false

      if last
        do elem.detach
        $(last).before elem

    do this.refresh

class TargetTimeList extends ElapsedTimeList
  insert: (elem, args...) ->
    super(elem, args...)

    $(elem).find('time').click =>
      do this.toggle_format

      return false

  toggle_format: ->
    @format = if @format is 'elapsed' then 'time' else 'elapsed'

    $('time', @elem).removeClass 'overtime'

    do this.update

  _update_time_display: (elem, elapsed) ->
    if not @format? or @format == 'time'
      elem.innerHTML = Date.format_elapsed elapsed
      return

    target = elem.getAttribute 'data-target'
    if not target?
      elem.innerHTML = ''
      return

    target = parseInt target

    rem = target - elapsed
  
    str = ''
    elem = $ elem
    if rem < 0
      elem.addClass 'overtime'
    else
      str += '+'
      elem.removeClass 'overtime'

    str += rem + ' min'

    elem.text str
          
class QueueList extends TargetTimeList
  add_sections: ->
    super

    li = $('<li></li>')
    li.attr('data-role', 'list-divider')
    li.attr('data-theme', 'a')
    li.attr('data-place', 'false')
    li.text 'Upcoming Reservations'

    @elem.append li
    
    do this.refresh

$.fn.queueList = ->
  new QueueList(this)
