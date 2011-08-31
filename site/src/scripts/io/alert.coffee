window.$IO ?= {}

class Action
  status_on:
    progress: true
    success: true
    error: true

  auto_retry: true

  constructor: ->
    @attempts = 0

    @status = new $UI.Status

  success: (resp) ->
    if not resp or not resp.ok
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
    if @cancel
      status.actions ?= {}
      status.actions.cancel =
        func: =>
          do @cancel
        text: 'Cancel'
        style: 'cancel'

  do: ->
    @attempts++

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

  constructor: (@data) ->
    super

    @noun = @data.name

  success: (resp) ->
    super

    data.times.alerts ?= []
    data.times.alerts.append new Date

    data.alerted = true

  cancel: ->

  _do: ->
    opts =
      success: (args...) =>
        @success(args...)
      error: (args...) =>
        @error(args...)

    if @data.alert_method == 'sms'
      $M.send_sms(@data.phone, 'Your table is ready! Please visit the host stand to be seated.', opts)
    else if @data.alert_method == 'call'
      $M.make_call(@data.phone, 'Your table is ready! Please visit the host stand to be seated.', opts)

$IO.alert = (data) ->
  (new AlertAction(data)).do()
