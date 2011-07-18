class IsotopeList
  constructor: (@elem) ->
    @dynamics_added = false

  add_dynamics: ->
    @dynamics_added = true

    $elem = $ @elem
    $elem.isotope
      itemSelector: 'li:not(.ui-li-divider)'
      layoutMode: 'sectionList'
      groupBy: 'elapsed'
      transformsEnabled: false
      getSortData:
        elapsed: ($el) ->
          parseInt $el.find('time').attr('data-minutes')
      sortBy: 'elapsed'
      getGroupData:
        elapsed:
          sections:
            [
              label: '0-10 mins'
              attrs:
                'data-start': 0
            ,
              label: '11-30 mins'
              attrs:
                'data-start': 11
            ,
              label: '31-60 mins'
              attrs:
                'data-start': 31
            ,
              label: '61+ mins'
              attrs:
                'data-start': 61
            ]
          map: (el, $sections) ->
            elapsed = parseInt $('time', el).attr 'data-minutes'

            last = null
            $.each $sections, (i, $sec) ->
              start = parseInt $sec.attr 'data-start'

              if start > elapsed
                return false

              last = i

            return last

    
    # Isotope will set the height after the elements are added.  If their
    # are enough elements, the scroll bar will appear, shifting the els.
    # We have to refresh it after the height is set, so the widths can
    # be corrected.
    $elem.isotope('reLayout')

    $(window).bind 'smartresize.isotope', ->
      # Temp fix to page resizing problem (header shows up too high).
      $.fixedToolbars.hide(true)


  refresh: ->
    if @dynamics_added
      $(@elem).isotope 'destroy'
      do @add_dynamics

class TimeList extends IsotopeList
  constructor: (@elem) ->
    super

    $$(@elem).time_list = this

    do this.add_sections

  add_sections: ->

  refresh: ->
    if @elem.jqmData 'listview'
      @elem.listview 'refresh'

    super

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

#      @elem.append li

    do this.refresh

  insert: (elem, elapsed=null) ->
    if not elapsed
      # We can pass in elapsed time to avoid having to parse it twice
      elapsed = parseInt $('time', elem).attr 'data-minutes'

    $('time', elem).time()

    $(@elem).append elem

    do this.refresh

  update: ->
    self = this

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
      $(@elem).find('time').time 'toggle_format'

      return false
          
class QueueList extends TargetTimeList
  add_sections: ->
    super

    li = $('<li></li>')
    li.attr('data-role', 'list-divider')
    li.attr('data-theme', 'a')
    li.attr('data-place', 'false')
    li.text 'Upcoming Reservations'

    #@elem.append li
    
    do this.refresh

$.fn.queueList = (action) ->
  if not action?
    return new QueueList(this)
  return $$(this).time_list[action]()
