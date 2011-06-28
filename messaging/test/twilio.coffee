twilio = require('../lib/twilio')

module.exports.testSms = (test) ->
  test.expect(1)

  sms = new twilio.SMS
  sms.send('4155992671', '2482298031', 'Test', (res) ->
    res.on 'processed', (params, resp) ->
      test.equals(params.SmsStatus, 'sent')

      test.done()
  )
