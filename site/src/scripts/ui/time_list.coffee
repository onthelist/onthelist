class IsotopeList
  constructor: (@elem) ->
    @dynamics_added = false

  add_dynamics: ->
    @dynamics_added = true

    use_transforms = ->
      # Using transforms prevents us from using percentage sizing, which
      # is required to allow the cols to smoothly expand when resized less
      # than the amount necessary to change the number of cols.
      #
      # Transforms also blur the text in Chrome.
      #
      # They are however required on the iPad, as (unlike the iPhone), it is
      # wide enough to use a diff number of cols on port. vs land., and requires
      # hardware accel. for the transformation to be smooth.
      #
      # So we use transforms on all mobile devices with tablet-like proportions.
      
      ua = navigator.userAgent
      if /mobile/i.test(ua) and (window.outerWidth > 480 or window.outerHeight > 480)

        return true
      return false

    sort_fields =
       remaining: ($el) ->
          $time = $('time', $el)

          elapsed = parseInt $time.attr 'data-minutes'
          target = parseInt $time.attr 'data-target'

          return target - elapsed
         
        elapsed: ($el) ->
          parseInt $el.find('time').attr('data-minutes')

        lname: ($el) ->
          name = $el.find('[data-key=name]').text()
          if name.indexOf(' ') == -1
            return name

          return name.substring(name.indexOf(' ') + 1)

    $elem = $ @elem
    $elem.isotope
      itemSelector: 'li:not(.ui-li-divider)'
      layoutMode: 'sectionList'
      groupBy: 'lname'
      transformsEnabled: use_transforms()
      getSortData: sort_fields
      sortBy: 'lname'
      getGroupData:
        lname:
          sections:
            [
              label: 'A-E'
              attrs:
                'data-start': 'A'
            ,
              label: 'F-L'
              attrs:
                'data-start': 'F'
            ,
              label: 'M-Z'
              attrs:
                'data-start': 'M'
            ]
          map: (el, $sections) ->
            lname = sort_fields.lname $(el)
            key = lname.substring(0, 1).toUpperCase()
            
            last = 0
            $.each $sections, (i, $sec) ->
              start = $sec.attr 'data-start'

              if key < start
                return false

              last = i

            return last
        
        remaining:
          sections:
            [
              label: '16+ mins over'
              attrs:
                'data-start': -16
            ,
              label: '0-15 mins over'
              attrs:
                'data-start': 0
            ,
              label: '1-15 mins rem'
              attrs:
                'data-start': 15
            ,
              label: '16+ mins rem'
              attrs:
                'data-start': '+'
            ]
          map: (el, $sections) ->
            rem = sort_fields.remaining $(el)

            last = 0
            $.each $sections, (i, $sec) ->
              start = $sec.attr 'data-start'

              if start == '+' or parseInt(start) >= rem
                last = i
                return false

            return last

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
            elapsed = sort_fields.elapsed $(el)

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

  refresh: ->
    if @dynamics_added
      $(@elem).isotope('reloadItems')

      # Necessary for webkit:
      iso = $(@elem).data('isotope')
      do iso._init
      
class TimeList extends IsotopeList
  constructor: (@elem) ->
    super

    $$(@elem).time_list = this

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

    @elem.append li
    
    do this.refresh

$.fn.queueList = (action) ->
  if not action?
    return new QueueList(this)
  return $$(this).time_list[action]()
