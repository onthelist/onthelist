nodemailer = require 'nodemailer'

nodemailer.SMTP =
    host: "smtp.gmail.com"
    port: 587
    ssl: false
    use_authentication: true
    user: "onthelisttest@gmail.com"
    pass: "test0000"

nodemailer.send_mail(
    sender: "\" On The List\" <onthelisttest@gmail.com>"
    to:"2485555555@txt.att.net"
    body:" Hi, how are you doing?"
  (error, success) ->
    console.log(error, success)
)
