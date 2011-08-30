function build_error(name, code){
  var err = function(msg){
    this.name = name + 'Error';
    this.code = code;
    this.msg = msg;

    Error.call(this, msg);
    Error.captureStackTrace(this, arguments.callee);
  };

  err.prototype.__proto__ = Error.prototype;

  module.exports[name] = err;
};

build_error('Unauthorized', 401);
build_error('Client', 400);
build_error('NotFound', 404);
build_error('Server', 500);
build_error('Unpaid', 402);

module.exports.respond = function(res, err){
  res.send({'ok': false, 'error': err.msg}, err.code);
};

module.exports.catch_errors = function(app){
  app.error(function(err, req, res, next){
    if(err.code)
      errors.respond(res, err)
    else
      next(err)
  });
};
