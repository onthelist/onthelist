TwilioClient = require('twilio').Client
Twiml = require('twilio').Twiml
EventEmitter = require('events').EventEmitter
sys = require('sys')
os = require('os')

notifiers = require('./base')
get_hostname = require('../../utils/lib/hostname').get_hostname

client_cache = null
create_client = (cb) ->
  if client_cache?
    cb client_cache
    return

  get_hostname (err, hostname) ->
    if err?
      console.log "Error loading hostname"
      console.log err
      sys.exit(1)

    client_cache = new TwilioClient(
      'AC8589ab3c89de18b914412699b12c1181',
      'e1f5c6fe7688ff64b7c6d5737b4cbd2b',
      hostname
    )

    cb client_cache

class TwilioSMS extends notifiers.SMS
  send: (from, to, msg, cb) ->
    create_client (client) ->
      client.simpleSendSms(from, to, msg, {}, cb)

wrap_resp = (resp) ->
  say: (msg) ->
    resp.append(new Twiml.Say(msg, {loop: 0}))

  send: ->
    resp.send()

class TwilioConversation extends EventEmitter
  constructor: (@call) ->
    @call.on 'answered', (params, resp) =>
      this.emit('answered', params, wrap_resp(resp))

class TwilioPhone extends notifiers.Phone
  call: (from, to, cb) ->

    create_client (client) ->
      call = client.makeCall(from, to, {})
      call.setup (c) ->
        cb(new TwilioConversation(c))

module.exports =
  SMS: TwilioSMS
  Phone: TwilioPhone
    
