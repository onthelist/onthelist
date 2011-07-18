$.extend $.Isotope.prototype,
  _getGroups: ->
    @groupData = @options.getGroupData ? {}
    @groupBy = @options.groupBy

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

      $el.html group.label

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

$.extend $.Isotope.prototype,
  _sectionListGetDims: ->
    @min_col_width = @sectionList.minColumnWidth ? 300
    @sectionList.colSpacing = @sectionList.columnSpacing ? 1

    @sectionList.numCols = @_sectionListNumCols()
    @sectionList.colWidth = (@width - @sectionList.colSpacing * (@sectionList.numCols - 1)) / @sectionList.numCols

  _sectionListNumCols: ->
    @width = @element.width()
    return Math.min(@sections.length, (Math.floor (@width / @min_col_width)) or 1)

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
    view_width = @element.width()

    return 100 * (px / view_width)

  _sectionListSetWidth: ($el) ->
    width = @sectionList.colWidth
    width -= parseFloat $el.css('padding-left')
    width -= parseFloat $el.css('padding-right')

    $el.width (@_sectionListWidthPercentage(width) + '%')

  _sectionListPlace: ->
    for lst, index in @sectionList.members
      coords = @sectionList.coords[index]
      $header = @sections[index].$el
      
      @_pushPosition $header, (@_sectionListWidthPercentage(coords.x) + '%'), coords.y

      @_sectionListSetWidth $header

      if not lst?
        continue

      y = coords.y + $header.outerHeight()
      x = coords.x
      for el in lst
        $el = $ el

        @_sectionListSetWidth $el

        @_pushPosition $el, (@_sectionListWidthPercentage(x) + '%'), y

        y += $el.outerHeight()

  _sectionListReset: ->
    @sectionList = {}

    $(@element).find('.section-header').remove()

    do @_getGroups
    do @_createGroups

  _sectionListLayout: ($elems) ->
    do @_sectionListGetDims
    @_sectionListMap $elems
    do @_sectionListGetPos
    do @_sectionListPlace

  _sectionListGetContainerSize: ->
    max_height = 0
    for section in @sections
      max_height += section.$el.outerHeight()

    for coords in @sectionList.coords
      max_height = Math.max(max_height, coords.y + coords.height)
        
    return {
      height: max_height
    }

  _sectionListResizeChanged: ->
    @sectionList.numCols != @_sectionListNumCols()
