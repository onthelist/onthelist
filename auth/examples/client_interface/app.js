/**
 * Module dependencies.
 */

var express = require('express');

var auth_routes = require('../../lib/routes');
var authenticator = require('../../lib/middleware');
var db = require('../../lib/db');
var errors = require('../../lib/errors');

var app = module.exports = express.createServer();

// Configuration

app.configure(function(){
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.bodyParser());
  app.use(express.query());
  app.use(express.methodOverride());
  app.use(express.cookieParser());
  app.use(authenticator());
  app.use(app.router);
  app.use(express.static(__dirname + '/public'));
});

app.configure('development', function(){
  db.use_test_dbs();
});

app.configure('production', function(){
});

// Routes

app.get('/', function(req, res){
  res.render('index', {
    title: 'Express'
  });
});

auth_routes.add_admin(app);
auth_routes.add_auth(app);

app.error(function(err, req, res, next){
  if (err.code)
    errors.respond(res, err);
  else
    next(err);
});

app.listen(3000);
console.log("Express server listening on port %d", app.address().port);
