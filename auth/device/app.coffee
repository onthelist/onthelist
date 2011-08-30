express = require('express')

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

DEVICES = {}
app.post '/register', (req, res) ->
  id = req.body.device_id

  device = req.body.device

  device.display_organization = 'Diablos'
  device.registered = true

  DEVICES[id] = device

  res.send
    device: device
    ok: true


app.get '/', (req, res) ->
  id = req.query.device_id

  if DEVICES[id]?
    res.send
      device: DEVICES[id]
      ok: true

  else
    res.send "Device not found", 404

app.listen(4313)
console.log("Express server listening on port %d", app.address().port)
