$.extend $.Isotope.prototype,
  _getGroups: (num_cols, guess_height) ->
    @groupData = @options.getGroupData ? {}
    @groupBy = @options.groupBy

    for own name, group of @groupData
      @_buildSection(group, num_cols, guess_height)

  _defaultSectionLabeler: (type, left, right) ->
    switch type
      when '-INF' then "Less Than #{left}"
      when 'INF' then "More Than #{left}"
      when 'range' then "#{left} - #{right}"
      when 'single' then left

  _buildSection: (group, num_cols, guess_height) ->
    lbl_maker = group.labelMaker ? @_defaultSectionLabeler
    group.num ?= 4
    if group.sectionBounds?
      # We need to divide up the sections.
      #
      # We are either provided a start and end, or an explicit list.
      if group.sectionBounds.length == 2
        # The bounds refer to the start and end of the total
        # range, we have to break it up into `num` chunks.
        #
        # `sectionBounds` is/will be a list of the 'edges' of
        # the sections, so the start of each section and the end
        # of the last section.
        if not group.allowPartialRows and group.num > num_cols
          # If we're not allowing partial rows, than we start at the
          # number of columns we can fit, and keep adding that number
          # until we're close enough to the target.
          num = num_cols
          while num + ((num_cols - 1) / 2) < group.num
            num += num_cols

        else
          num = group.num

        if group.vertDistribute and num_cols == 1
          # If we're one col, vertDistribute will keep adding groups
          # until there's enough that sections probably won't span
          # more than a page.
          while true
            height = guess_height(num)
            pages = @_estimateNumPages(height)

            if pages * 1.5 < num
              break
            
            num += 1

        if group.unboundedRight
          # Normally the last point represents the end, but if the right
          # side can go off into infinity, we don't need it.
          num -= 1

        s_bounds = @_listBounds(group.sectionBounds, num, group)

      else
        # The section edges were provided explicitly.
        s_bounds = group.sectionBounds

      # Expand the bounds into sections
      sections = []
      for bound, i in s_bounds
        start = bound
        if group.unboundedLeft and i == 0
          label = lbl_maker('-INF', bound)
          start = '-'
        else if group.unboundedRight and i == (s_bounds.length - 1)
          label = lbl_maker('INF', bound)
        else if i == (s_bounds.length - 1)
          # If the end is bounded, we will have one less section than
          # the # of bounds provided.
          continue
        else
          st_bound = bound
          en_bound = s_bounds[i + 1]
          
          if i != 0
            st_bound = @_shiftBound(st_bound)
           if i + 1 == s_bounds.length - 1
              # This is the last divider, the ending bound is one plus
              # the actual end.
              en_bound = @_shiftBound(en_bound, -1)

          if st_bound == en_bound
            # The start and end are the same (it's a single value)
            label = lbl_maker('single', st_bound)
          else
            label = lbl_maker('range', st_bound, en_bound)

        section =
          label: label
          attrs:
            'data-start': start

        sections.push section

      # Build the func to map a element into a section
      def_parse = (el) -> parseInt(el.text())
      func = group.parse ? def_parse
      map = (el, $sections) ->
        val = func(el)

        last = 0
        $.each $sections, (i, $sec) ->
          start = $sec.attr 'data-start'

          if start == '-'
            return

          if typeof val != 'string'
            start = parseInt start

          if start > val
            return false

          last = i

        return last

      group.sections = sections
      group.map = map

  _shiftBound: (bound, i=1) ->
    is_char = typeof bound == 'string'

    if is_char
      bound = bound.charCodeAt(0)

    bound += i

    if is_char
      bound = String.fromCharCode(bound)

    return bound

  _listBounds: (bounds, num, group) ->
    is_char = typeof bounds[0] == 'string'

    if is_char
      bounds = (b.charCodeAt(0) for b in bounds)

    @range = (bounds[1] - bounds[0]) + 1

    num = Math.min(@range + 1, num)

    incr = @range / num
    b = bounds[0]
    out = []
    for i in [0...num]
      out.push Math.floor(b + .5)

      b += incr

    # The points represent the dividing lines, we have to add a right margin.
    out.push (bounds[1] + 1)
    
    if group.unboundedLeft
      # If we start at -INF, the first bound is not the start of the first
      # range, it's the end of it, so the next bound has to take it's place.
      out[1] = out[0]

    if is_char
      out = (String.fromCharCode(o) for o in out)

    return out

  _createGroups: ->
    @groups = @groupData[@groupBy]

    @sections = []
    $last = null
    for group, i in @groups.sections
      $el = $ '<li></li>'
      $el.addClass('ui-li ui-li-divider ui-bar-b section-header')
      $el.css('top', 0).css('left', 0).css('position', 'absolute')
      $el.attr('data-role', 'list-divider')
      $el.attr('data-index', i)

      if group.attrs?
        for own name, val of group.attrs
          $el.attr name, val

      $el.html "<span class='ui-li-divider-inner'>#{group.label}</span>"

      if $last?
        $last.after $el
      else
        @element.prepend $el

      $last = $el

      @sections.push
        $el: $el
        opts: group

  _findSection: (el) ->
    if el.getAttribute('data-index')?
      return parseInt el.getAttribute('data-index')
    
    $sections = (s.$el for s in @sections)
    i = @groups.map(el, $sections)

    if i?
      return i

    throw "Invalid Section"
  
  _estimateNumPages: (height) ->
    page_size = $UI.get_page_space $('.ui-page-active')

    page_height = page_size[1] - 30

    return height / page_height

$.extend $.Isotope.prototype,
  _sectionListGetDims: ->
    @min_col_width = @sectionList.minColumnWidth ? 300
    @sectionList.colSpacing = @sectionList.columnSpacing ? 1

    @sectionList.numCols = @_sectionListNumCols()
    @sectionList.colWidth = (@width - @sectionList.colSpacing * (@sectionList.numCols - 1)) / @sectionList.numCols

  _sectionListNumCols: (limit=true) ->
    @width = @element.width()
    num = Math.floor(@width / @min_col_width) or 1

    if limit and @sections and @sections.length
      num = Math.min(@sections.length, num)

    return num

  _sectionListEstimateHeight: (num_elems, num_cols, num_sections) ->
    # Estimate the height so we can determine the right number of
    # sections to create such that there is a heading visible most
    # of the time, but all the space isn't consumed by headings.
    
    DIVIDER_HEIGHT = 33
    ELEMENT_HEIGHT = 46

    v_elem_cnt = num_elems / num_cols
    v_sec_cnt = num_sections / num_cols

    return ELEMENT_HEIGHT * v_elem_cnt + DIVIDER_HEIGHT * v_sec_cnt
 
  _sectionListMap: ($elems) ->
    self = this
    @sectionList.members = []

    for section in @sections
      @sectionList.members.push []

    $elems.each ->
      index = self._findSection this

      self.sectionList.members[index].push this

  _sectionListGetPos: ->
    @sectionList.coords = []

    col = row = 0
    max_row_height = y = 0
    for lst, index in @sectionList.members
      if col >= @sectionList.numCols
        col = 0
        row++

        y += max_row_height
        max_row_height = 0

      $header = @sections[index].$el

      height = $header.outerHeight()
      if lst?
        for el in lst
          height += $(el).outerHeight()

      if height > max_row_height
        max_row_height = height

      @sectionList.coords[index] =
        x: col * (@sectionList.colWidth + @sectionList.colSpacing)
        y: y
        height: height

      col++

  _sectionListWidthPercentage: (px) ->
    if @options.transformsEnabled
      # Transforms don't support percentage widths (meaning we will have
      # to redraw whenever the size is changed, even if we are using the
      # same # of cols.
      return px

    view_width = @element.width()

    return 100 * (px / view_width) + '%'

  _sectionListSetWidth: ($el) ->
    width = @sectionList.colWidth
    width -= parseFloat $el.css('padding-left')
    width -= parseFloat $el.css('padding-right')

    $el.width @_sectionListWidthPercentage(width)

  _sectionListPlace: ->
    for lst, index in @sectionList.members
      coords = @sectionList.coords[index]
      $header = @sections[index].$el
      
      @_pushPosition $header, @_sectionListWidthPercentage(coords.x), coords.y

      @_sectionListSetWidth $header

      if not lst?
        continue

      y = coords.y + $header.outerHeight()
      x = coords.x
      for el in lst
        $el = $ el

        @_sectionListSetWidth $el

        @_pushPosition $el, @_sectionListWidthPercentage(x), y

        y += $el.outerHeight()

  _sectionListReset: ->
    @sectionList = {}

    $(@element).find('.section-header').remove()

  _sectionListLayout: ($elems) ->
    num_cols = @_sectionListNumCols(false)

    guess_height = (num_sections) =>
      cols = Math.min(num_cols, num_sections)
      return @_sectionListEstimateHeight($elems.length, cols, num_sections)

    @_getGroups(num_cols, guess_height)
    do @_createGroups

    do @_sectionListGetDims
    @_sectionListMap $elems
    do @_sectionListGetPos
    do @_sectionListPlace

  _sectionListGetContainerSize: ->
    max_height = 0
    for section, i in @sections
      if i % @sectionList.numCols == 0
        max_height += section.$el.outerHeight()

    for coords in @sectionList.coords
      max_height = Math.max(max_height, coords.y + coords.height)

    return {
      height: max_height
    }

  _sectionListResizeChanged: ->
    # See _sectionListWidthPercentage
    @options.transformsEnabled or @sectionList.numCols != @_sectionListNumCols()
