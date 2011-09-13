store = require('../utils/lib/simpledb_store').client

name = process.argv[2]
display_name = process.argv[3]

store.putItem 'orgs', name,
    name: name
    display_name: display_name
    tokens: 10000
  ,
    console.log

