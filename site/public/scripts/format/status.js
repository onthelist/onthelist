(function() {
  var get_elapsed;
  get_elapsed = function(time) {
    return $F.date.format_elapsed(Date.get_elapsed(time), true);
  };
  window.$F.party = {
    status: function(obj) {
      if (obj.status.has('alerted')) {
        return "Alerted " + (get_elapsed(obj.times.alerts.last())) + " ago";
      }
      if (obj.status.has('waiting')) {
        return "Waiting " + (get_elapsed(obj.times.add));
      }
      if (obj.status.has('seated')) {
        return "Seated " + (get_elapsed(obj.times.seated)) + " ago";
      }
      return '';
    },
    alert_btn: function(obj) {
      if (obj.status.has('alerted')) {
        return "Alert Again";
      }
      return "Alert";
    }
  };
}).call(this);
