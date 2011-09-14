simpledb = require 'simpledb'

sdb = new simpledb.SimpleDB(
  keyid: 'AKIAJMHD4A33V6OWY6IQ'
  secret: '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'
)

module.exports =
  client: sdb

