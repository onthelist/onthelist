store = require('../utils/lib/simpledb_store').client

store.createDomain 'devices', console.log
store.createDomain 'orgs', console.log
