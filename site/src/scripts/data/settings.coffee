window.$D.settings ?= {}

$D.settings.default =
  look:
    theme: 'light'
  queue:
    sort: 'remaining'
    group: 'lname'
    time_view: 'remaining'

window.$S = $D.settings.default
if localStorage.settings
  $.extend true, $S, JSON.parse(localStorage.settings)

$S = $.extend({}, $D.settings.default,
  save: ->
    # The settings are specific to the device, so we use the device
    # id.
    localStorage.settings = JSON.stringify $S

    do $IO.sync.push 'settings', $S, $ID
)
