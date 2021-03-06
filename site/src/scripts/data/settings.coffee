window.$D.settings ?= {}

$D.settings.default =
  look:
    theme: 'light'
  queue:
    sort: 'elapsed'
    group: 'elapsed'
    time_view: 'elapsed'

window.$S = $D.settings.default
if localStorage.settings
  $.extend true, $S, JSON.parse(localStorage.settings)

$.extend window.$S,
  save: ->
    # The settings are specific to the device, so we use the device
    # id.
    localStorage.settings = JSON.stringify $S

    $IO.sync.push 'settings', $S, $ID
