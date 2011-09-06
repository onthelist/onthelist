(function() {
  window.$F.date = {
    format_elapsed: function(min, long) {
      var out;
      if (long == null) {
        long = false;
      }
      out = '';
      if (min > 59) {
        out += (Math.floor(min / 60)) + 'h ';
        min %= 60;
        if (min) {
          out += Math.floor(min) + 'm';
        }
      } else {
        out = Math.floor(min) + ' ' + (long ? 'minutes' : 'min');
      }
      if (min < 1) {
        out = Math.floor(min * 60) + ' sec';
      }
      return out;
    },
    format_remaining: function(min, plus, sec) {
      var str;
      if (plus == null) {
        plus = true;
      }
      if (sec == null) {
        sec = false;
      }
      str = '';
      if (plus && min > 0) {
        str = '+';
      }
      if (sec && min < 1 && min > 0) {
        return str + (Math.floor(min * 60) + 1) + ' sec';
      } else {
        return str + Math.floor(min) + ' min';
      }
    }
  };
}).call(this);
