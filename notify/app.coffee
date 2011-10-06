express = require('express')

logly = require('../utils/lib/logly')
store = require('../utils/lib/simpledb_store').client
sdb = require('../utils/lib/simpledb_helpers')

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
logly.log "Init SMS"

app.post '/send/sms', (req, res) ->
  id = req.body.device_id
  if not id
    logly.warn 'No device_id'
    throw new errors.Client "'device_id' param is required."

  sdb.get_org_from_device res, id, (org, device) ->
    if org.tokens <= 0
      logly.log "Out of tokens org:#{org.name}"
      errors.respond(res, new errors.Unpaid "NO_TOKENS")
      return

    org.tokens -= 1
    # This is a race condition, we could use Expect with retries
    # to avoid it.
    sdb.put_org res, org, ->
      to = req.body.to
      body = req.body.body

      if not to or not body
        logly.warn 'No to / body'
        errors.respond(res, new errors.Client "'to' and 'body' params are required.")
      
      sms.send('2482425222', to, body, ->
        logly.log "Sent SMS org:#{org.name} dev:#{id} to:#{to} tok:#{org.tokens}"
        logly.verbose "body:\"#{body}\""

        res.send
          ok: true
          tokens_remaining: org.tokens
      )

phone = new messaging.Phone()

app.post '/send/phone', (req, res) ->
  id = req.body.device_id
  if not id
    throw new errors.Client "'device_id' param is required."

  sdb.get_org_from_device res, id, (org, device) ->
    if org.tokens <= 0
      errors.respond(res, new errors.Unpaid "NO_TOKENS")
      return

    org.tokens -= 1
    
    sdb.put_org res, org, ->
      to = req.body.to
      body = req.body.body

      if not to or not body
        errors.respond(res, new errors.Client "'to' and 'body' params are required.")

      phone.call '2482425222', to, (convo) ->
        convo.on 'answered', (params, resp) ->
          resp.say body,
            loop: 0
          do resp.send

          res.send
            ok: true
            tokens_remaining: org.tokens

app.listen(5857)
console.log("Express server listening on port %d", app.address().port)
