window.$ID = localStorage.DEVICE_ID ? Math.floor(Math.random() * 100000000000000)
localStorage.DEVICE_ID = $ID

class Device extends Backbone.Model
  localStorage: new Store 'device'
  id: $ID

$D.device = new Device

$D.device.fetch()
if not $D.device.get 'created'
  # New device
  $.log 'unregistered device'
  $D.device.set
    create_time: new Date
    settings: $D.settings.default
    registered: false
    created: true

  do $D.device.save

window.$S = $.extend({}, $D.device.get('settings'),
  save: ->
    do $D.device.save
)
