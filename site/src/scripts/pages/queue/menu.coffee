$ ->
  $('#queue').bind 'pagecreate', ->
    $link = $('[href=#queue]', this)

    group_lbls = sort_lbls =
      'lname': 'Last Name'
      'remaining': 'Remaining Time'
      'elapsed': 'Elapsed Time'

    group_order = sort_order = ['lname', 'remaining', 'elapsed']

    $sel = $('<select></select>')
    $sel.addClass 'select-menu list-control'
    $sel.append $('<option></option>')
    $sel.append $('<option name="sort" value="sort" data-key="remaining">Sorted By: Remaining Time</option>')
    $sel.append $('<option name="group" value="group" data-key="lname">Grouped By: Last Name</option>')

    $li = $link.parent()
    $li.append $sel

    increment_sort = ->
      $opt = $sel.find('option[value=sort]')
      c_val = $opt.attr('data-key')

      index = sort_order.indexOf(c_val)
      index += 1
      index %= sort_order.length
      n_val = sort_order[index]

      $opt.text("Sorted By: #{sort_lbls[n_val]}")
      $opt.attr('data-key', n_val)

      $('#queue').trigger('sortUpdate', [n_val])

      menu.refresh(true)

    increment_group = ->
      $opt = $sel.find('option[value=group]')
      c_val = $opt.attr('data-key')

      index = group_order.indexOf(c_val)
      index += 1
      index %= group_order.length
      n_val = group_order[index]

      $opt.text("Grouped By: #{group_lbls[n_val]}")
      $opt.attr('data-key', n_val)

      $('#queue').trigger('groupUpdate', [n_val])

      menu.refresh(true)

    $sel.selectmenu
      nativeMenu: false

    $sel.change (e) ->
      val = $sel.val()
      $sel.val(null)

      if val == 'sort'
        do increment_sort
      else
        do increment_group

    menu = $sel.jqmData().selectmenu

    $li.find('.ui-select').hide()

    $link.bind 'vclick', ->
      if $link.hasClass 'ui-btn-active'
        if not menu.isOpen
          $sel.selectmenu 'open'

          top = $li.offset().top - menu.listbox.height() - 14
          menu.listbox.css 'top', top

          menu.listbox.find('.ui-btn-active').removeClass('ui-btn-active')
        else
          $sel.selectmenu 'close'

        return false

      return true
