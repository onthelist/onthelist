window.$UI ?= {}

class StatusList
  constructor: ->
    @entries = []

  register: (entry) ->
    @entries.push entry

list = new StatusList

class $UI.Status
  constructor: ->
    list.register this

    @shown = false

  update: (opts) ->
    @opts = opts

    for own name, action of @opts.actions
      if typeof action == 'function'
        @opts.actions[name] =
          func: action

    do @show

  _render_standalone: ->
    if not @$el?
      @$el = $ '<div />'
      @$el.addClass 'status-standalone'
      $('body').append @$el

    @$el.removeClass 'notice warning error success'
    @$el.addClass (@opts.style ? 'notice')

    if @opts.msg
      @$el.text @opts.msg

    if @opts.actions
      $act = $ '<div />'
      $act.addClass 'actions'
      @$el.append $act

      for own name, act of @opts.actions
        text = act.text ? name

        if act.link == false
          $a_el = $ '<span />'
        else
          $a_el = $ '<a href="#do" />'

        $a_el.html text

        if act.style?
          $a_el.addClass act.style

        $a_el.find('time').time
          format: 'remaining'
          sign: false

        self = this
        $a_el.find('a[href=#do]').andSelf()
          .attr('data-action', name)
          .bind 'vclick', (e) ->
            do e.preventDefault
            do e.stopPropagation

            action = self.opts.actions[$(this).attr('data-action')]
        
            do action.func

            false

        $act.append $a_el

  update_action: (name, opts) ->
    @opts.actions[name] ?= {}

    $.extend @opts.actions[name], opts

    do @show

  render: ->
    if @shown
      do @_render_standalone

  hide: ->
    @shown = false
    do @$el.hide

  show: ->
    timeout = @opts.ttl ? 5

    if @show_timeout?
      clearTimeout @show_timeout

    @shown = true

    if timeout != 0
      @show_timeout = setTimeout(=>
        do @hide
      , timeout * 1000)

    do @render

    @$el.show()
