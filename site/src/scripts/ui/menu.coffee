class Menu
  constructor: (@$elem, @opts) ->
    @submenu = @fields = @opts.fields

    do @_create_select
    do @_create_tab
    do @_init_menu

    @menu_stack = []

  _get_field: (name, fields=@submenu) ->
    for field in fields.options
      if field.name == name
        return field

    return null

  _create_tab: ->
    @$tab = $ '<div />'
    @$tab.addClass 'menu-tab ui-bar-e'
    @$tab.text '▲ Menu ▲'
    @$elem.parent().prepend @$tab

  _create_select: ->
    @$sel = $('<select></select>')
    @$sel.addClass 'select-menu list-control'
    @$elem.append @$sel

    do @_create_options

  _create_options: (fields=@fields) ->
    @$sel.html ''
    @$sel.append $('<option></option>')

    if @submenu != @fields
      $back = $('<option></option>')
      $back.text '< Back'
      $back.val '#back'
      @$sel.append $back

    for field in fields.options
      $opt = $('<option></option>')
      $opt.attr('value', field.name)
      @_update_option($opt, field, fields.value)

      @$sel.append $opt

    if fields.value?
      @$sel.val(fields.value)

    if @menu?
      @menu.refresh(true)

  _init_menu: ->
    @$sel.selectmenu
      nativeMenu: false

    @menu = @$sel.jqmData().selectmenu

    @$elem.find('.ui-select').last().hide()

    @$sel.change =>
      val = @$sel.val()
      # Reset the val so the same button can be clicked more than once.
      @$sel.val(null)

      field = @_get_field(val)

      if field?.type == 'toggle'
        @_toggle_val(val)
      else if @submenu == @fields
        @_show_submenu(val)
      else if val == '#back'
        do @_hide_submenu
      else
        @_set_val(val)

  _update_option: ($opt, field, parent_val) ->
    text = ''

    if field.value?
      # It is a container entry
      for opt in field.options
        if field.value == opt.name
          lbl = opt.label

      if field.label?
        text = "#{field.label}: "

      text += lbl

    else
      # It is a value entry
      text = field.label

      #if parent_val == field.name
        #  text = '* ' + text

    $opt.text text

  _show_submenu: (name, push=true, show=true) ->
    field = @_get_field(name) ? @fields

    @submenu = field

    @_create_options field

    if name and push
      @menu_stack.push(name)

    if show
      setTimeout(=>
        do @show
      , 0)

  _set_val: (val) ->
    @submenu.value = val
    @$elem.trigger('optionChange', [@submenu.name, val])

    @_hide_submenu true, false

  _toggle_val: (val) ->
    field = @_get_field(val)

    for opt in field.options
      if opt.name != field.value
        field.value = opt.name
        @$elem.trigger('optionChange', [val, field.value])

        @_create_options @submenu

        break
  
  _hide_submenu: (to_root=false, show=true) ->
    if to_root
      @menu_stack = []
    else
      @menu_stack.pop()

    name = @menu_stack.last() ? null
    
    @_show_submenu(name, false, show)
    
  show: ->
    @$sel.selectmenu 'open'

    top = @$elem.offset().top - @menu.listbox.height() - 14
    @menu.listbox.css 'top', top

    left = @$elem.offset().left + 30
    @menu.listbox.css 'left', left

    @menu.listbox.find('.ui-btn-active').removeClass('ui-btn-active')

  hide: ->
    @$sel.selectmenu 'close'

  toggle: ->
    if not @menu.isOpen
      do @show
    else
      do @hide

$.fn.menu = (opts) ->
  if typeof opts == 'string'
    return $$(this).menu[opts]()

  $$(this).menu = new Menu(this, opts)
