express = require('express')
store = require('../utils/lib/simpledb_store').client
sdb = require('../utils/lib/simpledb_helpers')
couch = require('../utils/lib/couch_store').client

errors = require('../utils/lib/errors')

app = module.exports = express.createServer()

# Configuration

app.configure ->
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
  
app.post '/:type/:name?', (req, res) ->
  id = req.body.device_id
  if not id
    throw new errors.Client "'device_id' param is required."

  type = req.params.type
  data = req.body[type]

  if not type? or not data
    throw new errors.Client "Parameters missing."

  name = req.params.name ? data.key ? "default#{type}"

  sdb.get_org_from_device res, id, (org, device) ->
    data._id = org.name + ':' + name

    couch.put data, (err) ->
      if err
        errors.respond res, new errors.Server "Error Saving."
        return

      res.send
        ok: true

app.get '/:type/:name?', (req, res) ->
  id = req.query.device_id
  if not id
    throw new errors.Client "'device_id' param is required."

  type = req.params.type
  if not type?
    throw new errors.Client "Type missing."

  name = req.params.name ? "default#{type}"

  sdb.get_org_from_device res, id, (org, device) ->
    couch.get
      db: 'sync_' + type
      _id: org.name + ':' + name
    
    , (err, data) ->

      console.log(data)
      if err or not data?
        errors.respond res, new errors.Server "Error Loading #{err}."
        return

      ret =
        ok: true

      ret[type] = data

      res.send ret

app.listen(6996)
console.log("Express server listening on port %d", app.address().port)
