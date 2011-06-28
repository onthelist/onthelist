/**
 * Merges objects.
 *
 * Arguments 1 through * are successivly merged into the object provided
 * as the first argument.  The first object is modified in place and also
 * returned.
 *
 * @param {Object} dest The object which the succeeding objects are applied
 *                      to.  This object is modified (use {} as the dest to
 *                      avoid altering the original).
 * @param {Object} sources The objects which are merged into dest.
 * @return {Object} dest
 */
function extend(){
  var dest = arguments[0];
  
  for (var i=1; i < arguments.length; i++){
    var from = arguments[i];
    if (!from)
      continue;

    var props = Object.getOwnPropertyNames(from);
    props.forEach(function(name) {
      if (name in dest) {
          var destination = Object.getOwnPropertyDescriptor(from, name);
          Object.defineProperty(dest, name, destination);
      } else {
        dest[name] = from[name];
      }
    });
  }

  return dest;
};

module.exports.extend = extend;
