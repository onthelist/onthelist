(function() {
  Date.prototype.setISO8601 = function(string) {
    var d, date, offset, regexp, time, _ref;
    regexp = "([0-9]{4})(-([0-9]{2})(-([0-9]{2})" + "(T([0-9]{2}):([0-9]{2})(:([0-9]{2})(\.([0-9]+))?)?" + "(Z|(([-+])([0-9]{2}):([0-9]{2})))?)?)?)?";
    d = string.match(new RegExp(regexp));
    offset = 0;
    date = new Date(d[1], 0, 1);
    if (d[3]) {
      date.setMonth(d[3] - 1);
    }
    if (d[5]) {
      date.setDate(d[5]);
    }
    if (d[7]) {
      date.setHours(d[7]);
    }
    if (d[8]) {
      date.setMinutes(d[8]);
    }
    if (d[10]) {
      date.setSeconds(d[10]);
    }
    if (d[12]) {
      date.setMilliseconds(Number("0." + d[12]) * 1000);
    }
    if (d[14]) {
      offset = (Number(d[16]) * 60) + Number(d[17]);
      offset *= (_ref = d[15] === '-') != null ? _ref : {
        1: -1
      };
    }
    offset -= date.getTimezoneOffset();
    time = Number(date) + (offset * 60 * 1000);
    return this.setTime(Number(time));
  };
  Date.get_minutes = function(date) {
    if (typeof date === 'string') {
      return (new Date).setISO8601(date);
    } else {
      return date.getTime();
    }
  };
  Date.get_elapsed = function(date) {
    date = Date.get_minutes(date);
    return ((new Date).getTime() - date) / 60000.0;
  };
}).call(this);
