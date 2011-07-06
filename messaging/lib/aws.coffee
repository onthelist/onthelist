aws = require 'aws-lib'

client = aws.createSESClient('AKIAIVOUX6BJJ4V5H6BQ', 'd9fiQvGQD1Six/R5pAnbJH7m+2GhwyCpTAhnNObd')

params =
  'Source': 'onthelistec2@gmail.com'
  'Destination.ToAddresses.member.1': '2482298031@txt.att.net'
  'Message.Subject.Data': 'a'
  'Message.Body.Text.Data': 'Test'


client.call("SendEmail", params, (resp) ->
  console.log resp)
