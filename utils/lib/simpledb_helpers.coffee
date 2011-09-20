errors = require('./errors')
store = require('./simpledb_store').client

wrap_json = (obj) ->
  for own name, val of obj
    if typeof val == 'object'
      obj[name] = 'json:' + JSON.stringify(val)

strip_json = (obj) ->
  for own name, val of obj
    if typeof val == 'string' and val.substring(0, 4) == 'json:'
      val = val.substring(5)
      obj[name] = JSON.parse(val)

module.exports =
  get: (domain, id, cb) ->
    store.getItem domain, id, (err, data) ->
      if data?
        strip_json data

      cb err, data

  put: (domain, id, data, cb) ->
    wrap_json data

    store.putItem domain, id, data, cb

  get_org: (res, name, cb) ->
    store.getItem 'orgs', name, (err, org, meta) ->
      if err
        errors.respond res, new errors.Server "Organization Load Error #{err}"
        return

      cb org, meta

  get_device: (res, id, cb) ->
    store.getItem 'devices', id, (err, device, meta) ->
      if err
        errors.respond res, new errors.Server "Device Load Error #{err}"
        return

      if device?._settings_str?
        device.settings = JSON.parse device._settings_str

      cb device, meta

  get_org_from_device: (res, id, cb) ->
    module.exports.get_device res, id, (device) ->
      module.exports.get_org res, device.organization, (org) ->
        cb org, device

  put_org: (res, org, cb) ->
    store.putItem 'orgs', org.name, org, (err) ->
      if err
        errors.respond res, new errors.Server "Error Saving Org #{err}"
        return

      do cb

  put_device: (res, device, cb) ->
    if device?.settings?
      device._settings_str = JSON.stringify device.settings

    store.putItem 'devices', device.id, device, (err) ->
      if err
        errors.respond res, new errors.Server "Error Saving Device #{err}"
        return

      do cb

