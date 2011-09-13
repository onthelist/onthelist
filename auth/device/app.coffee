express = require('express')

errors = require('../../utils/lib/errors')
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
  if req.body.auth.username != 'diablos' or req.body.auth.password != 'diablos'
    errors.respond res, new errors.NotFound "Credentials Invalid"
    return

  device = req.body.device
  org_name = 'diablos'

  sdb.get_org res, org_name, (org) ->
    device.display_organization = org.display_name
    device.registered = true
    device.organization = org_name
    device.id = id

    store.putItem 'devices', device.id, device, (err) ->
      if err
        errors.respond res, new errors.Server "Device Save Error #{err}"
        return

      res.send
        device: device
        ok: true

app.get '/', (req, res) ->
  id = req.query.device_id

  store.getItem 'devices', id, (err, data) ->
    if not err? and data?
      try
        device = data
      catch SyntaxError
        errors.respond res, new errors.Server "Stored data syntax error"
        return

      res.send
        device: device
        ok: true

    else if not err?
      errors.respond res, new errors.NotFound "Device not found"
    else
      errors.respond res, new errors.Server "Storage error: #{err}"

app.listen(4313)
console.log("Express server listening on port %d", app.address().port)
