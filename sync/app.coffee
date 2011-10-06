express = require('express')

logly = require('../utils/lib/logly')
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

init_req = (req) ->
  dev_id = req.query?.device_id ? req.body.device_id
  if not dev_id
    throw new errors.Client "'device_id' param is required."

  type = req.params.type
  if not type?
    throw new errors.Client "Type missing."

  name = req.params.name ? "default#{type}"

  return [dev_id, type, name]

_save = (req, res, id, type, name) ->
  data = req.body[type]

  if not data?
    throw new errors.Client "Data missing."

  sdb.get_org_from_device res, id, (org, device) ->
    couch.database("sync_#{type}").save org.name + ':' + name, data, (err, resp) ->
      if err
        errors.respond res, new errors.Server "Error Saving #{JSON.stringify(err)}"
        return

      res.send
        ok: true
        rev: resp.rev
  [id, type, name] = init_req req

_del = (req, res, id, type, name) ->
  sdb.get_org_from_device res, id, (org, device) ->
    db = couch.database "sync_#{type}"
    did = org.name + ':' + name

    db.get did,
      (err, data) ->
        if err?.reason == 'missing'
          errors.respond res, new errors.NotFound "Document missing"
          return

        if err or not data?
          console.log err
          errors.respond res, new errors.Server "Error Loading #{err?.message}."
          return

        db.remove did, data._rev, (err) ->
          if err
            errors.respond res, new errors.Server "Error Deleting."
            return

          res.send
            ok: true

app.post '/:type?/:name?', (req, res) ->
  [id, type, name] = init_req req

  logly.log_req req, "SAVE type:#{type} id:#{name} for dev:#{id}"

  _save req, res, id, type, name

app.delete '/:type/:name?', (req, res) ->
  [id, type, name] = init_req req

  logly.log_req req, "DEL type:#{type} id:#{name} for dev:#{id}"

  _del req, res, id, type, name

app.get '/:type/:name', (req, res) ->
  [id, type, name] = init_req req

  logly.log_req req, "FETCH type:#{type} id:#{name} for dev:#{id}"

  sdb.get_org_from_device res, id, (org, device) ->
    couch.database("sync_#{type}").get org.name + ':' + name,
      (err, data) ->
        if err?.reason == 'missing'
          errors.respond res, new errors.NotFound
          return

        if err or not data?
          errors.respond res, new errors.Server "Error Loading #{err?.message}."
          return

        ret =
          ok: true

        ret[type] = data

        res.send ret

app.get '/:type', (req, res) ->
  [id, type, name] = init_req req

  sdb.get_org_from_device res, id, (org, device) ->
    logly.log_req req, "FETCH_ALL type:#{type} org:#{org.name} dev:#{id}"

    couch.database("sync_#{type}").all
      include_docs: true
      startkey: JSON.stringify "#{org.name}:"
      endkey: JSON.stringify "#{org.name}:\ufff0"
    ,
      (err, data) ->
        if err?
          errors.respond res, new errors.Server "Error loading rows #{JSON.stringify(err)}"
          return

        out = []
        for r in data
          delete r.doc._id
          out.push r.doc

        res.send
          ok: true
          rows: out

app.listen(6996)
console.log("Express server listening on port %d", app.address().port)
