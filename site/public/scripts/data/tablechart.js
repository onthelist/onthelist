(function() {
  var ChartRack;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  ChartRack = (function() {
    __extends(ChartRack, $D._DataLoader);
    function ChartRack() {
      ChartRack.__super__.constructor.apply(this, arguments);
    }
    ChartRack.prototype.name = 'charts';
    return ChartRack;
  })();
  $D.charts = new ChartRack;
}).call(this);
