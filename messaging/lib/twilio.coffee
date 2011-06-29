TwilioClient = require('twilio').Client
Twiml = require('twilio').Twiml
EventEmitter = require('events').EventEmitter
sys = require('sys')

notifiers = require('./base')

client_cache = null
create_client = ->
  if not client_cache
    client_cache = new TwilioClient(
      'AC8589ab3c89de18b914412699b12c1181',
      'e1f5c6fe7688ff64b7c6d5737b4cbd2b',
      'zackbloom.doesntexist.org'
    )

  client_cache

class TwilioSMS extends notifiers.SMS
  constructor: (@name) ->
    @client = create_client()

  send: (from, to, msg, cb) ->
    @client.simpleSendSms(from, to, msg, {}, cb)

wrap_resp = (resp) ->
  say: (msg) ->
    resp.append(new Twiml.Say(msg))

  send: ->
    resp.send()

class TwilioConversation extends EventEmitter
  constructor: (@name, @call) ->
    @call.on 'answered', (params, resp) ->
      this.emit('answered', params, wrap_resp(resp))

class TwilioPhone extends notifiers.Phone
  constructor: (@name) ->
    @client = create_client()

  call: (from, to, cb) ->
    call = @client.makeCall(from, to, opts)
    call.setup (c) ->
      cb(new TwilioConversation(c))

module.exports =
  SMS: TwilioSMS
  Phone: TwilioPhone
    
