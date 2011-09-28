cradle = require 'cradle'

conn = new(cradle.Connection)(
  host: 'speedyseat.cloudant.com'
  port: 443
  cache: true
  raw: false
  secure: true
  auth:
    username: 'speedyseat'
    password: '9*3Hbu!9U'
)

module.exports =
  client: conn
