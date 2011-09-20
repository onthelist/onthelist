store = require('../utils/lib/simpledb_store').client

store.createDomain 'devices', console.log
store.createDomain 'orgs', console.log
store.createDomain 'users', console.log
store.createDomain 'sessions', console.log
store.createDomain 'sync_chart', console.log
