var db = require('../../utils/lib/db');

var mongoose = db.mongoose;

var AccountSchema = new mongoose.Schema({
  username: {'type': String, 'unique': true},
  passhash: String,
  salt: String
});

mongoose.model('Account', AccountSchema);


module.exports.Account = db.testable_model('Account', 'users');
