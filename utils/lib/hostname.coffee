http = require 'http'

module.exports.get_hostname = (cb) ->
  if process.env.SS_PUBLIC_HOSTNAME
    cb null, process.env.SS_PUBLIC_HOSTNAME
  
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
      data = data.strip()

      if data
        cb null, data
      else
        cb "No data"

  req.on 'error', (e) ->
    console.log "Hostname fetch socket error: #{e.message}"
    cb e

  do req.end
