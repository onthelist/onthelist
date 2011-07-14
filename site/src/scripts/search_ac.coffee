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
    @queue = $$('#queue-list').queue

  _handle_change: (evt) ->
    val = @$elem.val()
    if val == @last_val
      return true

    do this._abort_active
    
    @last_val = val

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

  _match: (val) ->
    field = @opts.field
    @queue.find((r) =>
      indx = r[field]?.indexOf val

      if indx == -1 or not indx?
        return false
      return @opts.match_anywhere or indx == 0

    , (args...) =>
      this._handle_match(args...)
    )

  _handle_match: (resp) ->
    $.log resp



$.fn.guest_search = (opts={}) ->
  $$(this).guest_search = new GuestSearchBox(this, opts)
