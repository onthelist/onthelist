class GuestSearchBox
  constructor: (@$elem, @opts={}) ->
    # We bind to change as well as keyup in case the user
    # pastes or uses another method for input, but we don't
    # want to bother loading the data twice, so we keep track
    # of the last input we executed on.
    @last_val = @$elem.val()

    @$elem.bind 'keyup change', (e) =>
      this._handle_change e

    @request = null
    @wait_timer = null
    @match = null
    @queue = $$('#queue-list').queue

    do this._add_button

  _add_button: ->
    @$button = $('<div></div>')
    @$button.buttonMarkup
      theme: 'c'

    @$button.addClass 'infield-button ui-corner-right empty'
    @$button.removeClass 'ui-btn-corner-all'

    @$elem.parent().append @$button

    @$button.bind 'vclick', (e) =>
      if @match?
        @$elem.trigger('fill', [@match, this, 'click'])

    @$elem.bind 'blur', (e) =>
      if @match?
        @$elem.trigger('fill', [@match, this, 'blur'])

  _handle_change: (evt) ->
    val = @$elem.val()
    if val == @last_val
      return true

    do this._abort_active
    
    @last_val = val

    if @match and @_check_match(@match, val)
      # If this still matches the already-loaded match
      # just update the type ahead text.
      do @_type_ahead
      return true
    else
      @match = null
    
    if val.length < 3
      return true

    if @wait_timer?
      clearTimeout @wait_timer

    @wait_timer = setTimeout(=>
      this._match val
    , 100)

    return true

  _abort_active: ->
    if @request?
      do @request.abort
      @request = null

  _check_match: (row, val) ->
    indx = row[@opts.field]?.indexOf val

    if indx == -1 or not indx?
      return false
    return @opts.match_anywhere or indx == 0

  _match: (val) ->
    do this._button_loading

    @queue.find((r) =>
      return this._check_match(r, val)
    , (args...) =>
      this._handle_match(args...)
    )

  _handle_match: (resp) ->
    if resp.length == 0
      @match = null
      do this._button_empty
      return
    
    @match = resp[0]

    if @$elem.triggerHandler('match', [@match, this]) == false
      @match = null
      return

    do this._button_ready

    do this._type_ahead

  _type_ahead: ->
    if @$elem.triggerHandler('typeAhead', [@match, this]) == false
      return

    val = @match[@opts.field]

    if @opts.format_type_ahead?
      val = @opts.format_type_ahead val

    entered = @$elem.val()
    @$elem.val val

    @$elem.caret(entered.length, val.length)

  _button_empty: ->
    @$button.text ''
    @$button.removeClass 'ready loading'
    @$button.addClass 'empty'

  _button_ready: ->
    @$button.text '↴'
    @$button.addClass 'ready'
    @$button.removeClass 'loading empty'

  _button_loading: ->
    @$button.text ''
    @$button.addClass 'loading'
    @$button.removeClass 'ready empty'

$.fn.guest_search = (opts={}) ->
  $$(this).guest_search = new GuestSearchBox(this, opts)
  return this
