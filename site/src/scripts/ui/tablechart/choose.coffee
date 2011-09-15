window.$TC.choose_table = (opts) ->
  $tc = $('#tablechart')
 
  prev_loc = window.location.toString()
  window.location = '#tablechart'

  _selection = (e, sel) ->
    sprite = $$(sel.selected).sprite

    if sprite.occupancy == undefined
      # Not selectable
      return
    
    window.location = prev_loc

    opts.success && opts.success(sprite)

    $tc.unbind 'scaled_selectableselected', _selection

  $tc.bind 'scaled_selectableselected', _selection
