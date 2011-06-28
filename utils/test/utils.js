var utils = require('../lib/utils');

exports.extend = {
  'basic': function(test){
    var dest = {
      'a': 1,
      'b': 2
    };
    var src = {
      'a': 3,
      'c': 4
    };
    var expect = {
      'a': 3,
      'b': 2,
      'c': 4
    }

    var out = utils.extend(dest, src);

    test.deepEqual(out, expect);
    test.deepEqual(dest, expect);
    test.deepEqual(src, {'a': 3, 'c': 4});

    test.done();
  },
  'multiple_inputs': function(test){
    var dest = {
      'a': 1,
      'b': 5
    };
    var src1 = {
      'a': 3,
      'd': 2
    };
    var src2 = {
      'c': 5,
      'a': 2
    };
    var expect = {
      'a': 2,
      'b': 5,
      'c': 5,
      'd': 2
    };

    var out = utils.extend(dest, src1, src2);

    test.deepEqual(out, expect);
    test.deepEqual(dest, expect);
    test.deepEqual(src1, {'a': 3, 'd': 2});
    test.deepEqual(src2, {'c': 5, 'a': 2});

    test.done();
  }
};
