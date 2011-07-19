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
      if /mobile/i.test(ua) and (window.outerWidth > 480 or window.outerHeight > 480 or true)

        return true
      return false

    sort_fields =
       remaining: (el) ->
          $time = $('time', el)

          elapsed = parseInt $time.attr 'data-minutes'
          target = parseInt $time.attr 'data-target'

          return (target - elapsed)
         
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
      sortBy: 'remaining'
      getGroupData:
        lname:
          num: 26
          vertDistribute: true
          sectionBounds: ['A', 'Z']
          parse: (el) ->
            lname = sort_fields.lname $(el)
            return lname.substring(0, 1).toUpperCase()
        remaining:
          sectionBounds: [-30, 30]
          unboundedLeft: true
          unboundedRight: true
          parse: (el) ->
            sort_fields.remaining(el)
        elapsed:
          sectionBounds: [0, 60]
          unboundedRight: true
          parse: (el) ->
            sort_fields.elapsed $(el)
    
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

  sort: (key) ->
    $(@elem)
      .trigger('beforeUpdate')
      .isotope({sortBy: key})
      .trigger('update')

  group: (key) ->
    $(@elem)
      .trigger('beforeUpdate')
      .isotope({groupBy: key})
      .trigger('update')
      
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

    $('time', elem).time
      format: 'remaining'

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

class QueueList extends ElapsedTimeList
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
