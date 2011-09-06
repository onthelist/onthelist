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
    self = this

    if not @$el?
      @$el = $ '<div />'
      @$el.addClass 'status-standalone'
      $page = $('.ui-page-active')
      $page.find('.ui-content').prepend @$el

      $('.ui-page').bind 'pageshow', ->
        do self.$el.detach
        $(this).find('.ui-content').prepend self.$el

    @$el.html ''

    @$el.removeClass 'notice warning error success'
    @$el.addClass (@opts.style ? 'notice')

    if @opts.msg
      $con = $ '<div />'
      $con.addClass 'status-msg'
      $con.html @opts.msg
      @$el.append $con

    if @opts.actions
      $act = $ '<div />'
      $act.addClass 'actions'
      @$el.append $act

      for own name, act of @opts.actions
        text = act.text ? name

        if act.status?
          $st = $ '<span />'
          $st.addClass 'action-status'

          $st.html act.status

          $act.append $st
          
          $st.find('time').time
            format: 'remaining'
            sign: false
            sec: true

        if act.link == false
          $a_el = $ '<span />'
        else
          $a_el = $ '<a href="#do" />'

        $a_el.html text

        if act.style?
          $a_el.addClass act.style

        $a_el.find('a[href=#do]').andSelf()
          .attr('data-action', name)
          .bind 'vclick', (e) ->
            do e.preventDefault
            do e.stopPropagation

            action = self.opts.actions[$(this).attr('data-action')]
        
            do action.func

            false

        $act.append $a_el

    $clr = $ '<hr />'
    $clr.addClass 'clear'
    @$el.append $clr

  update_action: (name, opts) ->
    @opts.actions[name] ?= {}

    $.extend @opts.actions[name], opts

    do @show

  render: ->
    if @shown
      do @_render_standalone

  hide: ->
    @shown = false
    if @$el?
      @$el.stop true
      do @$el.slideUp

  show: ->
    timeout = @opts.ttl ? 500

    if @show_timeout?
      clearTimeout @show_timeout

    @shown = true

    if timeout != 0
      @show_timeout = setTimeout(=>
        do @hide
      , timeout * 1000)

    do @render

#    @$el.stop true
    do @$el.slideDown
