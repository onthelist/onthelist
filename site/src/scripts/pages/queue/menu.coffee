$ ->
  $('#queue').bind 'pagecreate', ->
    _remaining_field =
      name: 'remaining'
      label: 'Remaining Time'

    _elapsed_field =
      name: 'elapsed'
      label: 'Elapsed Time'

    _lname_field =
      name: 'lname'
      label: 'Last Name'

    _size_field =
      name: 'size'
      label: 'Party Size'

    opts =
      fields:
        [
          name: 'time_view'
          default: 'remaining'
          label: 'View'
          options:
            [_remaining_field, _elapsed_field]
        ,
          name: 'sort'
          default: 'remaining'
          label: 'Sorted By'
          options:
            [_remaining_field, _elapsed_field, _lname_field, _size_field]
        ,
          name: 'group'
          default: 'lname'
          label: 'Grouped By'
          options:
            [_remaining_field, _elapsed_field, _lname_field, _size_field]
        ]

    $link = $('[href=#queue]', this)
    $li = $link.parent()
    $li.menu opts

    $link.bind 'vclick', ->
      if $link.hasClass 'ui-btn-active'
        $li.menu 'toggle'
        return false

      return true
