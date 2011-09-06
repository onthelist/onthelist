(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  $(function() {
    var $list, $page, add_el, cancel_el, hide_fake_page, last_title, show_fake_page, _bind_actions, _ref;
    last_title = false;
    add_el = false;
    cancel_el = false;
    $page = $('#queue');
    $list = $('#queue-list', $page);
    if ((_ref = window.$QUEUE) == null) {
      window.$QUEUE = {};
    }
    $QUEUE.check_out = function(id, success, failure) {
      return $D.parties.get(id, __bind(function(data) {
        if (!((data != null ? data.occupancy : void 0) != null)) {
          failure && failure();
          return;
        }
        data.add_status('left');
        data.times.left = new Date;
        data.occupancy = null;
        data.save();
        return success && success();
      }, this));
    };
    $QUEUE.check_in = function(id, success, failure) {
      return $TC.choose_table({
        success: __bind(function(table) {
          return $D.parties.get(id, __bind(function(data) {
            data.add_status('seated');
            data.times.seated = new Date;
            data.occupancy = {
              table: table.opts.key,
              chart: $TC.chart.opts.key
            };
            data.save();
            return success && success(table);
          }, this));
        }, this)
      });
    };
    _bind_actions = function() {
      var $links;
      $links = $list.find('a[href=#view-party]');
      return $links.each(function(i, el) {
        var $el;
        $el = $(el);
        return $el.bind('vclick', function() {
          var id;
          id = $el.attr('data-id');
          $QUEUE.check_in(id, function() {
            return hide_fake_page();
          });
          return false;
        });
      });
    };
    show_fake_page = function(self) {
      var add_list, link;
      _bind_actions();
      add_list = $('<ul></ul>');
      add_list.addClass('pseudo-list');
      add_el = $('<li></li>');
      add_list.append(add_el);
      link = $('<a></a>');
      add_el.append(link);
      link.addClass("list-action");
      link.text("Check-In Without Queue");
      $list.before(add_list);
      add_list.listview();
      cancel_el = $('<a></a>');
      cancel_el.attr('href', '#queue');
      cancel_el.addClass('ui-btn-left');
      $('a[href=#add-party]', $page).hide().before(cancel_el);
      cancel_el.buttonMarkup({
        icon: 'arrow-l',
        iconpos: 'notext'
      });
      cancel_el.bind('vclick', function() {
        return hide_fake_page(self);
      });
      $(self).hide();
      last_title = $('.ui-title:visible').text();
      return $('.ui-title:visible').text('Choose a Party');
    };
    hide_fake_page = function(self) {
      $('a[href=#add-party]').show();
      cancel_el.remove();
      add_el.remove();
      $(self).show();
      $('.ui-title:visible').text(last_title);
      return last_title = false;
    };
    return $('a[href=#check-in]').bind('vclick', function(e) {
      e.preventDefault();
      if (last_title) {
        hide_fake_page(this);
      }
      show_fake_page(this);
      return false;
    });
  });
}).call(this);
