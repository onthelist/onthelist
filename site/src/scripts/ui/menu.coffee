class Menu
  constructor: (@$elem, @opts) ->
    @fields = @_init_fields @opts.fields

    do @_create_select
    do @_init_menu

  _init_fields: (fields) ->
    for field in fields
      field._order = []
      field._labels = {}
      for opt in field.options
        field._order.push opt.name
        field._labels[opt.name] = opt.label

    return fields

  _get_field: (name) ->
    for field in @fields
      if field.name == name
        return field

    throw "Field not found"

  _create_select: ->
    @$sel = $('<select></select>')
    @$sel.addClass 'select-menu list-control'
    @$sel.append $('<option></option>')

    for field in @fields
      $opt = $('<option></option>')
      $opt.attr('value', field.name)
      @_update_option($opt, field, field.default)

      @$sel.append $opt

    @$elem.append @$sel

  _init_menu: ->
    @$sel.selectmenu
      nativeMenu: false

    @menu = @$sel.jqmData().selectmenu

    @$elem.find('.ui-select').last().hide()

    @$sel.change =>
      val = @$sel.val()
      # Reset the val so the same button can be clicked more than once.
      @$sel.val(null)

      @_increment(val)

  _update_option: ($opt, field, val) ->
    $opt.text "#{field.label}: #{field._labels[val]}"
    $opt.attr('data-key', val)

  _increment: (name) ->
    field = @_get_field(name)
    $opt = @$sel.find("option[value=#{name}]")
    c_val = $opt.attr('data-key')

    index = field._order.indexOf(c_val)
    index += 1
    index %= field.options.length
    n_val = field.options[index]

    @_update_option($opt, field, n_val.name)

    @$elem.trigger('optionChange', [name, n_val.name])
    
    @menu.refresh(true)

  toggle: ->
    if not @menu.isOpen
      @$sel.selectmenu 'open'

      top = @$elem.offset().top - @menu.listbox.height() - 14
      @menu.listbox.css 'top', top

      @menu.listbox.find('.ui-btn-active').removeClass('ui-btn-active')

    else
      @$sel.selectmenu 'close'

$.fn.menu = (opts) ->
  if typeof opts == 'string'
    return $$(this).menu[opts]()

  $$(this).menu = new Menu(this, opts)
