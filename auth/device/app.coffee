express = require('express')

errors = require('../../utils/lib/errors')
store = require('../../utils/lib/redis_store').client

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

  device.display_organization = 'Diablos'
  device.registered = true

  store.set "device:#{id}", JSON.stringify(device)
  store.set "device:#{id}:remaining_sms_tokens", 10000
  store.set "device:#{id}:remaining_phone_tokens", 10000

  res.send
    device: device
    ok: true

app.get '/', (req, res) ->
  id = req.query.device_id

  store.get "device:#{id}", (err, data) ->
    if not err? and data?
      try
        device = JSON.parse data
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
