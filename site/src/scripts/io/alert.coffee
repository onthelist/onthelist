window.$IO ?= {}

class Action
  status_on:
    progress: false
    success: false
    error: true

  auto_retry: true

  constructor: ->
    @attempts = 0

    @status = new $UI.Status

  success: (resp) ->
    if not resp or not resp.ok
      $TRACK.track 'alert-bad-resp'
      @error resp
      return

    @attempts = 0

    status =
      msg: "#{@noun} #{@post_verb}"
      style: 'success'

    if @status_on.success
      @status.update status
    else
      do @status.hide

  error: (resp, status, msg) ->
    $TRACK.track 'alert-error',
      status: status
      msg: msg
      attempt: @attempts
      elapsed: @elapsed

    if @attempts < 2 and @elapsed < 3
      # Nothing is an error until it has happened twice.
      setTimeout(=>
        @attempts++
        do @_do
      , 2000)
      return

    status =
      msg: "Error #{@adverb} #{@noun}"
      style: 'error'
      ttl: 0
      actions:
        retry: =>
          do @do

    @_add_cancel status

    if @status_on.error
      @status.update status
    else
      do @status.hide

    if @auto_retry
      delay = Math.pow(2, @attempts - 1) * 5

      @status.update_action 'retry',
        status: "Retrying in <time data-target='#{delay / 60}' datetime='#{(new Date).toISOString()}' data-format='remaining'></time>"
        text: 'Retry Now'

      timeout = setTimeout(=>
        @status.update_action 'retry',
          status: null
          link: false
          text: 'Retrying Now'

        @attempts++
        do @_do
      , delay * 1000)

      @status.update_action 'cancel',
        text: 'Cancel'
        func: =>
          clearTimeout timeout
          do @status.hide

  _add_cancel: (status) ->
    if @cancel?
      status.actions ?= {}
      status.actions.cancel =
        func: =>
          $TRACK.track 'alert-cancel'
          do @cancel
        text: 'Cancel'
        style: 'cancel'

  do: ->
    @attempts++

    start = new Date
    @__defineGetter__ 'elapsed', ->
      (new Date).secondsSince start

    status =
      msg: "#{@adverb} #{@noun}"

    @_add_cancel status

    if @status_on.progress
      @status.update status
    else
      do @status.hide

    do @_do

class AlertAction extends Action
  adverb: "Alerting"
  post_verb: "Alerted"
  noun: "Guest"

  constructor: (@data, opts={}) ->
    super

    @noun = @data.name

    # opts override the properties of the object, but we must be
    # careful not to modify any objects in place, lest we change
    # the class's defaults.
    for name, val of @
      if not opts[name]?
        continue

      if Object.isObject val
        @[name] = $.extend(true, {}, val, opts[name])
      else
        @[name] = opts[name]

  success: (resp) ->
    super

    @data.times.alerts ?= []
    @data.times.alerts.push new Date

    @data.remove_status 'alerting'
    @data.add_status 'alerted'
    @data.save false

  error: ->
    @data.remove_status 'alerting'
    @data.save false

    super

  cancel: ->
    @data.remove_status 'alerting'
    @data.save false

  _do: ->
    @data.add_status 'alerting'
    @data.save false

    opts =
      success: (args...) =>
        @success(args...)
      error: (args...) =>
        @error(args...)

    switch @data.alert_method
      when 'sms'
        $TRACK.track 'alert-sms'
        $M.send_sms(@data.phone, 'Your table is ready! Please visit the host stand to be seated.', opts)
      when 'call'
        $TRACK.track 'alert-call'
        $M.make_call(@data.phone, 'Your table is ready! Please visit the host stand to be seated.', opts)
      when 'wait'
        $TRACK.track 'alert-wait'
        alert "Please call waiting guest #{@data.name}"
        @success
          ok: true
      when 'page'
        $TRACK.track 'alert-page'
        alert "Please page ##{@data.pager_number}"
        @success
          ok: true

$IO.alert = (args...) ->
  (new AlertAction(args...)).do()
