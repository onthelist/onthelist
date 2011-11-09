$ ->
  $('#add-party').bind 'pageshow', ->
    key = do $PAGE.get_arg
    
    $title = $('.ui-title', this)
    $button = $('#add-party-submit', this).parent().children('.ui-btn-inner').children('.ui-btn-text')

    if not key?
      $title.text "Add a Party"
      $button.text "Add"
      $$(this).data = {}
    else
      $title.text "Edit Party"
      $button.text "Save"

      $inputs = $('input, select', this)
      
      $D.parties.get key, (data) =>
        if not data
          alert 'Record not found'
          return

        $$(this).data = data

        for own name, val of data
          $inp = $inputs.filter("[name=#{name}]")
          
          if $inp.attr('data-type') == 'range'
            $inp.trigger 'forceVal', val
          else if $inp.filter("[type=radio], [type=checkbox]").length
            $inp.attr('checked', false)
            $inp.filter("[value=#{val}]").attr('checked', true)
          else
            $inp.val val

          $inp.trigger 'refresh'

        $inputs.filter("[type=checkbox], [type=radio]").checkboxradio("refresh")
        $inputs.filter("select").not("[data-role=slider]").selectmenu("refresh")
        $inputs.filter("[data-role=slider]").slider('refresh')
