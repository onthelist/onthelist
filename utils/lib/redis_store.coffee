redis = require 'redis'

client = do redis.createClient

client.on 'error', (err) ->
  console.log err

module.exports =
  client: client
