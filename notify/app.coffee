express = require('express')

db = require('../utils/lib/db')
errors = require('../utils/lib/errors')

auth_routes = require('../auth/lib/routes')
authenticator = require('../auth/lib/middleware')

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
  
  app.use(authenticator())
  
  app.use(app.router)
  app.use(express.static(__dirname + '/public'))


app.configure 'development', ->
  db.use_test_dbs()
#  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))

app.configure 'production', ->
  #  app.use(express.errorHandler())

app.error (err, req, res, next) ->
  if err.code
    errors.respond(res, err)
  else
    next(err)

# Routes

auth_routes.add_admin(app)
auth_routes.add_auth(app)
  
sms = messaging.SMS()

app.post '/send/sms', (req, res) ->
  req.auth.require 'send-sms'

  to = req.body.to
  body = req.body.body

  if not to or not body
    throw new errors.Client "'to' and 'body' params are required."
  
  sms.send('4155992671', to, body, ->
    res.send('ok': true)
  )

app.listen(5857)
console.log("Express server listening on port %d", app.address().port)
