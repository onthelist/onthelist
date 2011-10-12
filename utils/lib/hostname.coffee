http = require 'http'

module.exports.get_hostname = (cb) ->
  if process.env.SS_PUBLIC_HOSTNAME?
    cb null, process.env.SS_PUBLIC_HOSTNAME
    return
  
  data = ''

  req = http.request
    host: '169.254.169.254'
    port: 80
    method: 'GET'
    path: '/latest/meta-data/public-hostname'

  , (resp) ->
    resp.on 'data', (chunk) ->
      data += chunk

    resp.on 'end', ->
      data = data.toString()

      if data
        cb null, data
      else
        cb "No data"

  req.on 'error', (e) ->
    console.log "Hostname fetch socket error: #{e.message}"
    cb e, 'localhost'

  do req.end

if not module.parent
  module.exports.get_hostname (err, hostname) ->
    if err
      console.log err
      process.exit(1)

    console.log hostname
    process.exit(0)

