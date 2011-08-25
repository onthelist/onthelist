class SwipeMenu
  constructor: (@$elem, @opts) ->
    do @_bind_events

  _bind_events: ->
    @$elem.bind 'dragstart', ->
      false

    @$elem.bind 'swiperight showSwipeMenu', =>
      do @_show_buttons
      true

    @$elem.bind 'swipeleft vclick hideSwipeMenu', =>
      do @_hide_buttons
      true

  _show_buttons: ->
    @$b_cont = $ '<div />'
    @$b_cont.addClass 'swipe-button-container'

    @$slide_cont = $ '<div />'
    @$slide_cont.addClass 'swipe-button-slide'
    @$b_cont.append @$slide_cont

    @$elem.append @$b_cont

    for action in @opts.actions
      $button = $ '<a />'
      $button.text action.label

      $button.bind 'vclick', ((action) =>
        (e) =>
          do e.stopPropagation
          do e.preventDefault

          do action.cb

          do @_hide_buttons
        )(action)

      @$slide_cont.append $button

      $button.buttonMarkup
        inline: true
        theme: action.theme ? 'b'

    @$b_cont.css('width', 0).animate({'width': '200px'}, 200)

  _hide_buttons: ->
    if @$b_cont?
      @$b_cont.animate {'width': 0}, 200, 'swing', =>
        do @$b_cont.remove

jQuery.fn.swipe_menu = (opts) ->
  (new SwipeMenu($(this), opts))
