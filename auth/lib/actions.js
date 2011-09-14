var uuid = require("uuid");
var hashlib = require("hashlib");

var utils = require('../../utils/lib/utils');
var errors = require('../../utils/lib/errors');
var store = require('../../utils/lib/simpledb_store').client;

var SESSION_TTL = 3600; // In sec

/**
 * Generate a hash for a password.
 *
 * Each user account stores both a password hash and a random salt used to
 * hash that user's password.  Unique salts limit the effectiveness of
 * rainbow tables and dictionary attacks in cracking passwords.
 *
 * @param {string} password Plaintext password.
 * @param {string} salt Randomly generated salt stored with the user account.
 */
var hashPassword = function(password, salt){
  return hashlib.sha1(password + salt);
};

/**
 * Create a user account in the users database.
 *
 * @param {function} cb Called when complete if there is no error.
 * @param {string} username The username used for auth.  Must be unique.
 * @param {string} password The password to be used for authentication.
 * @param {Object} doc Optional additional properties to be stored with the user.
 * @raises
 */
module.exports.createAccount = function(username, password, doc, cb){
  if (!username || !password){
    return cb(new errors.Client('Username and password must be provided.'));
  }

  doc = doc || {};

  var salt = uuid.generate();
  var passhash = hashPassword(password, salt);

  var account = {};
  account.username = username;
  account.passhash = passhash;
  account.salt = salt;

  utils.extend(account, doc);

  store.putItem('users', username, account, function(err){
    if (err)
      return cb(new errors.Server(err));

    cb();
  });
};

/**
 * Load a user document with a specified username.
 *
 * @param {string} username
 * @param {function} cb Called with user doc.
 */
module.exports.getUser = function(username, cb){
  store.getItem('users', username, function(err, doc){
    if (err)
      return cb(new errors.Server("Error loading user doc"));
    if (!doc)
      return cb(new errors.NotFound("User doc not found"));

    // The mapper will ignore attempts to delete elements, but this works.
    doc.passhash = undefined;
    doc.salt = undefined;

    cb(undefined, doc);
  });
};

/**
 * Load the authentication session associated with an authentication token.
 *
 * Loaded sessions will contain the user's username.
 */
module.exports.getSession = function(token, cb){
  store.getItem('sessions', token, function(err, sess){
    if (err || !sess)
      return cb(new errors.Unauthorized('Unable to load authentication session.'));

    delete sess.cookie;

    cb(undefined, sess);
  });
};

/**
 * Wrap 'get_user' to get user involved with the session associated with
 * the provided token.
 *
 * @param {string} token The authentication token provided by 'login'.
 * @param {function} cb See 'get_user'.
 */
module.exports.getSessionUser = function(token, cb){
  module.exports.getSession(token, function(err, data){
    if (err)
      return cb(err);

    module.exports.getUser(data.username, cb);
  });
};

/**
 * Delete the session details, logging user out.
 */
module.exports.logout = function(token, cb){
  store.deleteItem(token, function(err){
    if (err)
      return cb(new errors.Server(err));
    
    cb();
  });
};

module.exports.checkLogin = function(username, password, cb){
  if (!username || !password){
    return cb(new errors.Client('Username and password must be provided.'));
  }

  store.getItem('users', username, function(err, doc){
    if (err)
      return cb(new errors.Server("Error loading user doc"));
    if (!doc)
      return cb(new errors.NotFound("Username or password not found"));

    var salt = doc.salt;
    var hash = doc.passhash;
    if (!salt || !hash)
      return cb(new errors.Server("No salt and/or hash in user account"));

    var gen_hash = hashPassword(password, salt);

    if (!gen_hash || gen_hash !== hash){
      // For security, we don't identify that this is a valid username.
      return cb(new errors.NotFound("Username or password not found"));
    }

    doc.salt = undefined;
    doc.hash = undefined;

    cb(undefined, doc);
  });
};

/**
 * Authenticate a user.
 *
 * This will NOT end existing sessions the user may have.
 *
 * @param {string} username
 * @param {string} password
 * @param {function} cb
 */
module.exports.login = function(username, password, cb){
  module.exports.checkLogin(username, password, function(err, username){
    if (err)
      return cb(err);

    var token = uuid.generate();

    var session = {
      'username': username,
      'start_time': (new Date).getTime()
    };
    store.putItem('sessions', token, session, function(err){
      if (err)
        return cb(new errors.Server(err));

      cb(undefined, token);
    });
  });
};

