$ ->
  $('#add-party').bind 'pageshow', ->
    key = $$('#queue-list').selected_key
    
    $title = $('.ui-title', this)
    $button = $('[href=#add] .ui-btn-text', this)

    if not key?
      $title.text "Add a Party"
      $button.text "Add"
    else
      $title.text "Edit Party"
      $button.text "Save"

      $inputs = $('input, select', this)
      
      $D.queue.get key, (data) =>
        if not data
          alert 'Record not found'
          return

        for own name, val of data
          $inp = $inputs.filter("[name=#{name}]")
          
          if $inp.attr('data-type') == 'range'
            $inp.trigger 'forceVal', val
          else
            $inp.val val

          $inp.trigger 'refresh'

        $inputs.filter("[data-type=checkbox], [data-type=radio]").checkboxradio("refresh")
        $inputs.filter("select").not("[data-role=slider]").selectmenu("refresh")
        $inputs.filter("[data-role=slider]").slider('refresh')
