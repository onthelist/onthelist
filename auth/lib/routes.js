var errors = require('../../utils/lib/errors');

var actions = require('./actions');

module.exports.add_admin = function(app){
  app.post('/account', function(req, res){
  // Disabled so initial accts can be created.
  //  req.auth.require('create_account');
    
    var username = req.body.username;
    var password = req.body.password;

    actions.createAccount(username, password, {}, function(err){
      if (err)
        return errors.respond(res, err);
      
      res.send({'ok': true});
    });
  });
};

module.exports.add_auth = function(app){
  app.get('/_session/user', function(req, res){
    req.auth.require();

    req.auth.getUser(function(err, doc){
      if (err)
        return errors.respond(res, err);

      res.send(doc);
    });
  });

  app.get('/_session', function(req, res){
    req.auth.require();

    res.send(req.auth.session);
  });

  app.del('/_session', function(req, res){
    req.auth.require();

    // Don't forget to delete cookie or session var, if using.

    req.auth.logout(function(){
      res.send({'ok': true});
    });
  });

  app.post('/_session', function(req, res){
    var username = req.body.username;
    var password = req.body.password;

    actions.login(username, password, function(err, token){
      if (err)
        return errors.respond(res, err);

      // We could also set the token in a cookie or session here, e.g.:
      res.cookie('authToken', token);

      res.send({
        'ok': true,
        'authToken': token
      });
    });
  });
};
