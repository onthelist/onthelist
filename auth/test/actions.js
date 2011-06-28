var testCase = require('nodeunit').testCase;
var uuid = require('uuid');
var hashlib = require('hashlib');

var db = require('../../utils/lib/db');

var actions = require('../lib/actions');
var schema = require('../lib/schema');

db.use_test_dbs();

function createAccount(obj, cb){
  obj.username = uuid.generate();
  obj.password = uuid.generate();

  actions.createAccount(obj.username, obj.password, {}, cb);
};

function login(obj, cb){
  actions.login(obj.username, obj.password, function(err, token){
    obj.token = token;

    cb(err, token);
  });
};

var ensureLogout = {
  'test': function(test, obj, cb){
    actions.getSessionUser(obj.token, function(err, doc){
      test.notEqual(err, undefined);
      test.equal(doc, undefined);

      cb();
    })
  },
  'expect': 2
}
    
module.exports = testCase({
  setUp: function (cb){
    createAccount(this, cb);
  },
  tearDown: function (cb){
    schema.Account.remove(cb);
  },
  login: function(test){
    test.expect(2);

    var self = this;
  
    login(self, function(err){
      test.ok(self.token);
      test.equal(err, undefined);

      test.done();
    });
  },
  badPassword: function(test){
    test.expect(1 + ensureLogout.expect);

    var self = this;

    actions.login(this.username, 'aaaa', function(err){
      test.notEqual(err, undefined);

      ensureLogout.test(test, self, function(){    
        test.done();
      });
    });
  },
  badUsername: function(test){
    test.expect(1 + ensureLogout.expect);

    var self = this;

    actions.login('aaaa', 'aaaa', function(err){
      test.notEqual(err, undefined);

      ensureLogout.test(test, self, function(){    
        test.done();
      });
    });
  },
  logout: function(test){
    test.expect(2 + ensureLogout.expect);

    var self = this;

    login(self, function(err){
      test.equal(err, undefined);

      actions.logout(self.token, function(err){
        test.equal(err, undefined);

        ensureLogout.test(test, self, function(){
          test.done();
        });
      });
    });
  },
  getSessionUser: function(test){
    test.expect(3);

    var self = this;

    login(self, function(err){
      actions.getSessionUser(self.token, function(err, doc){
        test.equal(err, undefined);
        test.notEqual(doc, undefined);

        test.equal(doc && doc.username, self.username);

        test.done();
      });
    });
  }
});
