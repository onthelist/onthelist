window.$ID = localStorage.DEVICE_ID ? Math.floor(Math.random() * 100000000000000).toString()
localStorage.DEVICE_ID = $ID

class Device extends Backbone.Model
  localStorage: new Store 'device'
  id: $ID

  save: ->
    if $D.device.get('registered')
      $TRACK.name_tag $D.device.get('display_organization')

    super

$D.device = new Device

$D.device.fetch()
if typeof $D.device.attributes.settings != 'object'
  $D.device.attributes.settings = {}

if not $D.device.get 'created'
  # New device
  $.log 'unregistered device'
  $D.device.set
    create_time: new Date
    settings: {}
    registered: false
    created: true
 
  $D.device.attributes.settings = $.extend(true, {}, $D.settings.default, $D.device.attributes.settings)
  do $D.device.save

do $IO.fetch_device

window.$S = $.extend({}, $D.device.get('settings'),
  save: ->
    do $D.device.save
)
