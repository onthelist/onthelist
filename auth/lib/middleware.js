var errors = require('../../utils/lib/errors');
var utils = require('../../utils/lib/utils');

var actions = require('./actions');

/**
 * Looks for a auth token and creates an auth object in the 
 * request representing the authenticated session.
 *
 * The middleware looks for the authToken element in the following locations:
 *  - req.auth
 *  - POST body
 *  - GET params
 *  - session
 *  - as a cookie
 *
 * req.auth is searched to allow preceeding middleware to specify the token.
 *
 * The properties of the auth object (req.auth) are documented in this
 * function.
 *
 * @middleware
 */
module.exports = function(){
  return function(req, res, next){
    req.auth = req.auth || {};

    var token = null;
    var potential_locations = [
      req.auth,
      req.body,
      req.query,
      req.session,
      req.cookies
    ];

    for (var i=0; i < potential_locations.length; i++){
      var loc = potential_locations[i];

      if (loc && (loc.authToken || loc.authtoken)){
        // Cookies may lowercase key
        token = loc.authToken || loc.authtoken;
        break;
      }
    }

    /**
      * Wraps 'can', raising an exception where 'can' returns false.
      */
    req.auth.require = function(){
      if (!this.can.call(this, arguments))
        throw new errors.Unauthorized("Unauthorized");
    };

    if (token){
      actions.getSession(token, function(err, sess){
        if (err)
          return next(err);

        sess.token = token;
        
        /**
        * Determine if a user is authenticated and (optionally) has specific
        * permissions.
        *
        * If called with no arguments, returns true if a user is logged in,
        * false otherwise.
        *
        * If called with any number of string arguments, returns true iff
        * a user is logged in and has ALL of the permissions enumerated in 
        * the arguments.
        *
        * @param {String} The name of a permission which the user must have.
        *                 Any number of such strings may be passed in.
        *
        * @return {Boolean} If the user is authenticated and has necessary perms.
        * @dummy
        */
        var can = function(){
          return true;
        }

        /**
         * Return the Account document for the authenticated user.
         */
        var getUser = function(cb){
          actions.getUser(sess.username, cb);
        };

        /**
         * End the authenticated session.
         */
        var logout = function(cb){
          actions.logout(token, cb);
        };

        var auth = {
          'can': can,
          'getUser': getUser,
          'logout': logout,
          'session': sess
        };

        utils.extend(req.auth, auth);

        next();
      });
    } else {
      // The user is not authenticated

      req.auth.can = function(){
        return false;
      }

      next();
    }
  }
}
