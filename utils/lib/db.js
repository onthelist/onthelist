var mongoose = require('mongoose');

var HOST = 'localhost';

var connection_cache = {};

/**
 * Connects to a MongoDB database.
 * 
 * Connections are cached.  Connection errors are not yet checked, but 
 * connections will only be cached if/when they successfully fire the
 * 'open' event.
 * 
 * The server being connected to is a constant and in the future may be 
 * changed based on the environment.
 *
 * As Mongoose buffers requests, the Connection object will be returned
 * before it is open.  It is possible that the connection will not be
 * successful, calling code should be prepared to handle the exception even
 * after this function returns and, as always, to handle failures in succeding
 * db operations.
 *
 * @param {string} db The name of the database
 * @return {Connection} The Mongoose Connection object for this host and db.
 */
module.exports.get_db = function(db){
  if (db in connection_cache)
    return connection_cache[db];

  var conn = mongoose.createConnection('mongodb://' + HOST + '/' + db);

  // TODO: Handle errors on connect
  conn.on('open', function(){
    connection_cache[db] = conn;
  });

  // Mongoose buffers requests until the connection is ready, so
  // it's not necessary to wait until it's ready to return.
  return conn;
};

var USE_TEST_DBS = false;
module.exports.use_test_dbs = function(){
  USE_TEST_DBS = true;
};

module.exports.testable_model = function(model_name, db_name){
  if (USE_TEST_DBS)
    db_name += '_test';

  return module.exports.get_db(db_name).model(model_name);
};

module.exports.mongoose = mongoose
