(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  $('#view-party').live('pageshow', function() {
    var key, self;
    self = this;
    key = $$('#queue-list').selected_key;
    $('[data-key]', self).text('');
    return $D.parties.get(key, function(data) {
      var $alert_lbl, do_delete, fmt_phone, _update_button;
      if (!data) {
        alert('Record not found');
        return;
      }
      $$(self).data = data;
      $('[data-key=name]', self).text(data.name);
      $('[data-key=size]', self).text(data.size);
      $('[data-key=notes]', self).text(data.notes);
      $('[data-key=status]', self).text($F.party.status(data));
      $('time.icon', self).attr('datetime', data.times.add).attr('data-target', data.quoted_wait).time({
        format: 'icon'
      });
      $alert_lbl = $('[name=alert_party] .ui-btn-text', self);
      _update_button = __bind(function() {
        return $alert_lbl.text($F.party.alert_btn(data));
      }, this);
      data.bind('status:change', _update_button);
      $(self).bind('pagehide', function() {
        return data.unbind('status:change', _update_button);
      });
      _update_button();
      if (data.status.has('seated')) {
        $('[name=check_in]', self).hide();
        $('[name=clear_table]', self).show();
      } else {
        $('[name=check_in]', self).show();
        $('[name=clear_table]', self).hide();
      }
      fmt_phone = $F.phone(data.phone);
      $('#text-actions-menu li[tabindex=-1] a').text("Call Guest at " + fmt_phone).attr("href", "tel:" + data.phone).bind('vclick', function() {
        document.location = $(this).attr('href');
        return false;
      });
      do_delete = function() {
        $D.parties.remove(data);
        $(self).dialog('close');
        $(this).unbind('vclick', do_delete);
        return false;
      };
      return $('a[href=#delete-party]', self).bind('vclick', do_delete);
    });
  });
}).call(this);
