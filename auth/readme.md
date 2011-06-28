Authentication Tools
===================

An Express/MongoDB authentication implementation.

Elements
=======

Account Schema (lib/schema.js)
------

Defines a schema for Account documents in the database.

Currently includes the bare minimum (username, password details) but
will be extended to include additional details in the future (perms, etc.)

Actions (lib/actions.js, tests/actions.js)
------

Actions which may be applied to accounts:

- Login
- Logout
- Create Account
- Get Session
- Get User
- Get Session User (helper)

Middleware (lib/middleware.js)
-----

A Connect/Express middleware to support authentication.

Adds `auth` element to the request object including the username and the
following methods:

- `can`
  - If no arguments are given, returns true iff the user is logged in.
  - If provided with string arguments, returnts true iff the user is logged in and
    has the specified permissions.  Permissions themselves are not yet supported.

- `require`
   Same as `can`, but has no return value and raises an Unauthorized exception where `can` returns false.

- `logout`
   End current session.

- `getUser`
   Fetch the session user's Account document.

Note that the `auth` element is always included, even if a user is not logged in. 
Use `can` or `require` to verify that a user is logged in.

### Example
```javascript
    var authenticator = require('../../lib/middleware');

    app.configure(function(){
      // To search for authToken in:
      app.use(express.cookieParser()); // cookies
      app.use(express.bodyParser()); // post body
      app.use(express.query()); // query string
      app.use(express.session()); // session

      // To allow users to logout on clients which don't support HTTP DELETE:
      app.use(express.methodOverride());

      app.use(authenticator());
      app.use(app.router);
    });

    app.get('/', function(req, res){
      req.auth.require();

      // Only logged in users will make it here without an exception.

      req.auth.require('edit-documents', 'eat-pie');

      // Only users with the two perms will get here.

      if (req.auth.can('digest-pie')){

        // Only users with the 'digest-pie' perm here.

        console.log(req.auth.session.username);

        req.auth.getUser(function(err, user){
          // Do something with user doc
      
          // Log user out
          req.auth.logout();
        });
      }
    }
```

Routes (lib/routes.js)
======

Adds routes for account admin and/or auth to any Express server.

- add_admin will add:
  - create_account at POST /account with params `username` and `password`.
- add_auth will add:
  - login at POST /_session with params `username` and `password`.
  - logout at DELETE /_session.
  - get session at GET /_session.
  - get session user at GET /_session/user.

See examples/client_interface/app.js for an example.

Store (lib/store.js)
=====

Exposes a Connect Store object.

Redis backed store is currently enabled, but MemoryStore can be activated
if Redis is not installed.

Client Interface Example (examples/client_interface/)
=====

A simple client-side demo of auth. 

### To Run:
- Install / start MongoDB
- Install / start Redis, or disable it in lib/storage.js
- Ensure the libuuid1 and uuid-dev packages are installed
- Install all deps by running `npm -d --dev install` in the root directory.
- Run `node examples/client_interface/app.js`

If you experiance module loading issues, make sure NODE_PATH is set correctly.

Tests
=====
### To Run:
- Run `nodeunit tests/<whichever file>.js`

Utils (lib/utils.js, tests/utils.js)
=====

Includes a function to merge objects.
