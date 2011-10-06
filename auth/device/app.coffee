express = require('express')

logly = require('../../utils/lib/logly')
errors = require('../../utils/lib/errors')
auth = require('../lib/actions')
store = require('../../utils/lib/simpledb_store').client
sdb = require('../../utils/lib/simpledb_helpers')

app = module.exports = express.createServer()

app.configure(->
  app.set('views', __dirname + '/views')
  app.set('view engine', 'jade')
  app.use(express.bodyParser())
  app.use(express.methodOverride())
  app.use(app.router)
  app.use(express.static(__dirname + '/public'))
)

app.configure('development', ->
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))
)

app.configure('production', ->
  app.use(express.errorHandler())
)

errors.catch_errors app

app.post '/register', (req, res) ->
  id = req.body.device_id

  logly.log_req req, "REGISTER dev:#{id} username:#{req.body.auth.username}"

  auth.checkLogin req.body.auth.username, req.body.auth.password, (err, user) ->
    if err?
      errors.respond res, err
      return

    org_name = user.organization
    device = req.body.device

    sdb.get_org res, org_name, (org) ->
      device.display_organization = org.display_name
      device.registered = true
      device.organization = org_name
      device.nickname = req.body.nickname
      device.id = id

      sdb.put_device res, device, ->
        res.send
          device: device
          ok: true

app.get '/', (req, res) ->
  id = req.query.device_id
  if not id?
    errors.respond res, new errors.Client "You must provide a device id"
    return

  logly.log_req req, "FETCH dev:#{id}"

  if typeof id == 'number'
    id = id.toString()

  sdb.get_device res, id, (device) ->
    if device?
      res.send
        device: device
        ok: true

    else
      errors.respond res, new errors.NotFound "Device not found"

app.listen(4313)
console.log("Express server listening on port %d", app.address().port)
