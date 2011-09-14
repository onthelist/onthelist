actions = require('../auth/lib/actions')

org = process.argv[2]
name = process.argv[3]
pass = process.argv[4]

actions.createAccount(name, pass, {'organization': org}, console.log)
