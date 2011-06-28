class Notifier
  constructor: (@name) ->

  send: (opts) ->

class SMSNotifier extends Notifier
  send: (from, to, msg, cb) ->

class PhoneNotifier extends Notifier
  make: (from, to, cb) ->

module.exports =
  'Phone': PhoneNotifier
  'SMS': SMSNotifier

