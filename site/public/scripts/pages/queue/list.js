(function() {
  var add_list_row, save_row_key, _ref;
  if ((_ref = window.$QUEUE) == null) {
    window.$QUEUE = {};
  }
  $QUEUE.show_view_page = function(key) {
    $$('#queue-list').selected_key = key;
    return window.location = '#view-party';
  };
  save_row_key = function() {
    return $$('#queue-list').selected_key = this.getAttribute('data-id');
  };
  add_list_row = function(list, row) {
    var e_name, e_size, e_slice, e_time, el, elapsed, i, link, qw, size;
    el = $('<li></li>');
    el.addClass(row.status.join(' '));
    row.bind('status:change', function(e, status, prev) {
      el.removeClass(prev.join(' '));
      return el.addClass(status.join(' '));
    });
    link = $('<a></a>');
    link.attr('href', '#view-party');
    link.attr('data-id', row.key);
    link.bind('vclick', save_row_key);
    el.append(link);
    elapsed = Date.get_elapsed(row.times.add);
    e_time = $('<time>' + $F.date.format_elapsed(elapsed) + '</time>');
    e_time.attr('data-minutes', elapsed);
    e_time.attr('datetime', row.times.add);
    e_time.attr('data-format', $S.queue.time_view);
    if (row.quoted_wait) {
      qw = parseInt(row.quoted_wait);
      e_time.attr('data-target', qw);
    }
    link.append(e_time);
    e_name = $('<span></span>');
    e_name.attr('data-key', 'name');
    e_name.text(row.name);
    link.append(e_name);
    size = row.size;
    for (i = 1; 1 <= size ? i <= size : i >= size; 1 <= size ? i++ : i--) {
      e_slice = $('<span class="ui-li-count slice">1</span>');
      e_slice.css('right', (38 + 2 * (size - i)) + 'px');
      link.append(e_slice);
    }
    e_size = $('<span class="ui-li-count" data-key="size"></span>');
    e_size.text(size);
    link.append(e_size);
    link.swipe_menu({
      actions: [
        {
          label: 'Alert',
          theme: 'e',
          cb: function() {
            return $IO.alert(row, {
              status_on: {
                success: false,
                progress: false
              }
            });
          }
        }, {
          label: 'Check-In',
          cb: function() {
            return $QUEUE.check_in(row.key);
          }
        }
      ]
    });
    return list.insert(el, elapsed);
  };
  $(function() {
    var list, q_elem;
    q_elem = $('#queue-list');
    list = q_elem.queueList($S.queue);
    $('#queue').bind('pageshow', function() {
      list.add_dynamics();
      return $$(q_elem).selected_key = void 0;
    });
    q_elem.bind('heightChange', function() {
      return $.fixedToolbars.show(true);
    });
    $('#queue').bind('optionChange', function(e, name, val) {
      $S.queue[name] = val;
      $S.save();
      switch (name) {
        case 'sort':
          return list.sort(val);
        case 'group':
          return list.group(val);
        case 'time_view':
          return q_elem.find('time').time('toggle_format');
      }
    });
    $D.parties.live('rowAdd', function(e, row) {
      var elapsed;
      if (!row.status.has('waiting')) {
        return;
      }
      elapsed = Date.get_elapsed(row.times.add);
      return add_list_row(list, row);
    });
    return $D.parties.bind('rowRemove', function(e, row) {
      if (list) {
        return list.remove($('a[data-id=' + row.key + ']', q_elem).parents('li').first());
      }
    });
  });
}).call(this);
