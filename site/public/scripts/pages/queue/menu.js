(function() {
  $(function() {
    return $('#queue').bind('pagecreate', function() {
      var $li, $link, opts, _elapsed_field, _lname_field, _remaining_field, _size_field;
      _remaining_field = {
        name: 'remaining',
        label: 'Remaining Time'
      };
      _elapsed_field = {
        name: 'elapsed',
        label: 'Elapsed Time'
      };
      _lname_field = {
        name: 'lname',
        label: 'Last Name'
      };
      _size_field = {
        name: 'size',
        label: 'Party Size'
      };
      opts = {
        fields: {
          options: [
            {
              name: 'time_view',
              value: $S.queue.time_view,
              label: 'Viewing',
              options: [_remaining_field, _elapsed_field]
            }, {
              name: 'sort',
              value: $S.queue.sort,
              label: 'Sorted By',
              options: [_remaining_field, _elapsed_field, _lname_field, _size_field]
            }, {
              name: 'group',
              value: $S.queue.group,
              label: 'Grouped By',
              options: [_remaining_field, _elapsed_field, _lname_field, _size_field]
            }
          ]
        }
      };
      $link = $('[href=#queue]', this);
      $li = $link.parent();
      $li.menu(opts);
      return $link.bind('vclick', function() {
        if ($link.hasClass('ui-btn-active')) {
          $li.menu('toggle');
          return false;
        }
        return true;
      });
    });
  });
}).call(this);
