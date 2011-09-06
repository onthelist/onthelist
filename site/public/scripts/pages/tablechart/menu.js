(function() {
  $(function() {
    return $('#tablechart').bind('pagecreate', function() {
      var $li, $link, opts;
      opts = {
        fields: {
          options: [
            {
              name: 'edit',
              value: 'locked',
              type: 'toggle',
              options: [
                {
                  name: 'locked',
                  label: 'Edit Table Chart'
                }, {
                  name: 'unlocked',
                  label: 'Stop Editing'
                }
              ]
            }
          ]
        }
      };
      $link = $('[href=#tablechart]', this);
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
