express = require('express')

app = module.exports = express.createServer()

app.configure ->
  app.use(express.bodyParser())
  app.use(express.methodOverride())
  app.use(app.router)
  #app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))

app.post '/console', (req, res) ->
  console.log(req.socket.remoteAddress, req.body)

  res.send('ok': true)

app.error (args...) ->
  console.log(args)

app.listen(7777)
console.log("Express server listening on port %d", app.address().port)
