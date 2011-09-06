(function() {
  window.$F.phone = function(d) {
    var cod, pre, reg;
    pre = d.slice(0, 3);
    reg = d.slice(3, 6);
    cod = d.slice(6);
    return "(" + pre + ") " + reg + "-" + cod;
  };
}).call(this);
