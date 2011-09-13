errors = require('./errors')
store = require('./simpledb_store').client

module.exports =
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

