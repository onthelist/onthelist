express = require('express')
store = require('../utils/lib/redis_store').client

errors = require('../utils/lib/errors')
messaging = require('../messaging/lib/auto')

app = module.exports = express.createServer()

# Configuration

app.configure ->
  app.set('views', __dirname + '/views')
  app.set('view engine', 'jade')
  
  app.use(express.bodyParser())
  app.use(express.query())
  app.use(express.methodOverride())
  app.use(express.cookieParser())
  
  app.use(app.router)


app.configure 'development', ->
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))

app.configure 'production', ->
  app.use(express.errorHandler())

errors.catch_errors app

# Routes
  
sms = new messaging.SMS()

app.post '/send/sms', (req, res) ->
  id = req.body.device_id
  if not id
    throw new errors.Client "'device_id' param is required."

  store.decr "device:#{id}:remaining_sms_tokens", (err, count) ->
    if err?
      errors.respond(res, new errors.Server "Error fetching count: #{err}")

    else if count < 0
      errors.respond(res, new errors.Unpaid "NO_SMS_TOKENS")

    else
      to = req.body.to
      body = req.body.body

      if not to or not body
        errors.respond(res, new errors.Client "'to' and 'body' params are required.")
      
      sms.send('2482425222', to, body, ->
        res.send('ok': true)
      )

phone = new messaging.Phone()

app.post '/send/phone', (req, res) ->
  id = req.body.device_id
  if not id
    throw new errors.Client "'device_id' param is required."

  store.decr "device:#{id}:remaining_phone_tokens", (err, count) ->
    if err?
      errors.respond(res, new errors.Server "Error fetching count: #{err}")

    else if count < 0
      errors.respond(res, new errors.Unpaid "NO_PHONE_TOKENS")

    else
      to = req.body.to
      body = req.body.body

      if not to or not body
        errors.respond(res, new errors.Client "'to' and 'body' params are required.")

      phone.call '2482425222', to, (convo) ->
        convo.on 'answered', (params, resp) ->
          resp.say body
          do resp.send

          res.send('ok': true)

app.listen(5857)
console.log("Express server listening on port %d", app.address().port)
