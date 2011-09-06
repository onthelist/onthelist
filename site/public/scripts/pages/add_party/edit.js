(function() {
  var __hasProp = Object.prototype.hasOwnProperty, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  $(function() {
    return $('#add-party').bind('pageshow', function() {
      var $button, $inputs, $title, key;
      key = $$('#queue-list').selected_key;
      $title = $('.ui-title', this);
      $button = $('[href=#add] .ui-btn-text', this);
      if (!(key != null)) {
        $title.text("Add a Party");
        return $button.text("Add");
      } else {
        $title.text("Edit Party");
        $button.text("Save");
        $inputs = $('input, select', this);
        return $D.parties.get(key, __bind(function(data) {
          var $inp, name, val;
          if (!data) {
            alert('Record not found');
            return;
          }
          $$(this).data = data;
          for (name in data) {
            if (!__hasProp.call(data, name)) continue;
            val = data[name];
            $inp = $inputs.filter("[name=" + name + "]");
            if ($inp.attr('data-type') === 'range') {
              $inp.trigger('forceVal', val);
            } else if ($inp.filter("[type=radio], [type=checkbox]").length) {
              $inp.attr('checked', false);
              $inp.filter("[value=" + val + "]").attr('checked', true);
            } else {
              $inp.val(val);
            }
            $inp.trigger('refresh');
          }
          $inputs.filter("[type=checkbox], [type=radio]").checkboxradio("refresh");
          $inputs.filter("select").not("[data-role=slider]").selectmenu("refresh");
          return $inputs.filter("[data-role=slider]").slider('refresh');
        }, this));
      }
    });
  });
}).call(this);
