(function() {
  $(function() {
    $('#add-party').bind('pagecreate', function() {
      return $('.ui-input-text', this).each(function(i, el) {
        if (el.value) {
          return el.setAttribute('data-default', el.value);
        }
      });
    });
    $('#add-party').bind('pageshow', function() {
      var $pages, page, _clear;
      page = this;
      $pages = $('.ui-page').not(this);
      _clear = function() {
        $('.ui-input-text', page).each(function(i, el) {
          var _ref;
          return el.value = (_ref = el.getAttribute('data-default')) != null ? _ref : '';
        });
        return $pages.unbind('pageshow', _clear);
      };
      $pages.bind('pageshow', _clear);
      return $('.ui-input-text', this).first().focus();
    });
    return $('#add-party a[href=#add]').bind('vclick', function(e) {
      var dia, key, vals, _ref, _ref2;
      dia = $('#add-party');
      vals = (_ref = $$(dia).data) != null ? _ref : {};
      $('#add-party input').each(function(i, elem) {
        var $elem;
        $elem = $(elem);
        if ($elem.filter('[type=checkbox], [type=radio]').length) {
          if ($elem.attr('checked') === 'checked') {
            return vals[$elem.attr('name')] = $elem.val();
          }
        } else {
          return vals[$elem.attr('name')] = $elem.val();
        }
      });
      key = $$('#queue-list').selected_key;
      if (key) {
        vals.key = key;
      }
      if ((_ref2 = vals.status) == null) {
        vals.status = ['waiting'];
      }
      $D.parties.save(vals);
      dia.dialog('close');
      return false;
    });
  });
}).call(this);
