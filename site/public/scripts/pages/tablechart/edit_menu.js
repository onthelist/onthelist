(function() {
  var __hasProp = Object.prototype.hasOwnProperty;
  $(function() {
    return $('#tablechart').bind('pagecreate', function() {
      var $add, $del, $form, $label, $menu, $rots, $size, $types, last_rotation, sprites, _add_handler, _clear_selection, _handlers, _remove_handlers;
      $menu = $('.editor', this);
      $form = $('form', $menu);
      $size = $('[data-key=size]', $form);
      $types = $('[name=type]', $form);
      $label = $('[name=label]', $form);
      $rots = $('#table-rotation a', $form);
      $del = $('[name=del-table]', $menu);
      $del.button('disable');
      last_rotation = 0;
      $menu.bind('vclick', function(e) {
        var _ref;
        if ((_ref = e.target.tagName) !== 'A' && _ref !== 'SPAN' && _ref !== 'BUTTON' && _ref !== 'INPUT') {
          return $menu.toggleClass('manual-open');
        }
      });
      $add = $('a[href=#add-table]', $menu);
      $add.bind('vclick', function() {
        var lbl, num, opts, spr, tci, type, x, y, _ref, _ref2, _ref3, _ref4, _ref5;
        num = parseInt($size.val());
        x = 500;
        y = 250;
        tci = $('.tablechart-inner')[0];
        type = (_ref = $types.filter(':checked').attr('value')) != null ? _ref : 'RoundTable';
        lbl = $label.val();
        if (parseInt(lbl, 10) !== NaN) {
          lbl = parseInt(lbl, 10) + 1;
        }
        if (sprites && sprites[0]) {
          x = sprites[0].x + ((_ref2 = (_ref3 = $TC.gaps) != null ? _ref3.x : void 0) != null ? _ref2 : 40);
          y = sprites[0].y + ((_ref4 = (_ref5 = $TC.gaps) != null ? _ref5.y : void 0) != null ? _ref4 : 40);
        }
        opts = {
          seats: num,
          x: x,
          y: y,
          label: lbl,
          rotation: last_rotation
        };
        spr = $TC.chart.add(opts, type);
        $TC.chart.save();
        $TC.chart.draw();
        $(spr.canvas).trigger('select');
        window.spr = spr;
        $label.focus();
        $label.caret(0, 10);
        return false;
      });
      sprites = null;
      _clear_selection = function() {
        var sprite, _i, _len;
        _remove_handlers();
        $label.val('');
        $del.button('disable');
        $menu.removeClass('open');
        $menu.removeClass('docked-right');
        $menu.addClass('docked-left');
        if (sprites != null) {
          for (_i = 0, _len = sprites.length; _i < _len; _i++) {
            sprite = sprites[_i];
            sprite.pop_style();
          }
        }
        return sprites = null;
      };
      _handlers = {};
      _add_handler = function(name, $elems, evt, func) {
        if (evt == null) {
          evt = 'change';
        }
        _handlers[name] = {
          func: func,
          $elems: $elems,
          evt: evt
        };
        return $elems.bind(evt, _handlers[name].func);
      };
      _remove_handlers = function() {
        var name, obj;
        for (name in _handlers) {
          if (!__hasProp.call(_handlers, name)) continue;
          obj = _handlers[name];
          obj.$elems.unbind(obj.evt, obj.func);
        }
        return _add_handler('rotation', $rots, 'vclick', function(e) {
          return false;
        });
      };
      _remove_handlers();
      $('.tablechart-inner', this).bind('scaled_selectableselected', function(e, ui) {
        var $canvases, init_sel, s, sprite, _i, _len;
        init_sel = !(sprites != null);
        $canvases = $('.ui-selected', this);
        sprites = (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = $canvases.length; _i < _len; _i++) {
            s = $canvases[_i];
            _results.push($$(s).sprite);
          }
          return _results;
        })();
        for (_i = 0, _len = sprites.length; _i < _len; _i++) {
          sprite = sprites[_i];
          sprite.push_style('selected');
        }
        _remove_handlers();
        if ($(sprites[0].canvas).position().left < $menu.width()) {
          $menu.removeClass('docked-left');
          $menu.addClass('docked-right');
        }
        setTimeout(function() {
          return $menu.addClass('open', 0);
        });
        if (init_sel) {
          $size.trigger('forceVal', [sprites[0].seats]);
        }
        _add_handler('size', $size, 'change', function() {
          var sprite, _j, _len2, _results;
          _results = [];
          for (_j = 0, _len2 = sprites.length; _j < _len2; _j++) {
            sprite = sprites[_j];
            sprite.seats = this.value;
            _results.push(sprite.update());
          }
          return _results;
        });
        if (init_sel) {
          $types.attr('checked', false);
          $types.filter("[value=" + sprites[0].__proto__.constructor.name + "]").attr('checked', true);
          $types.checkboxradio('refresh');
        }
        _add_handler('types', $types, 'change', function() {
          var i, sprite, type, _len2, _results;
          type = this.value;
          _results = [];
          for (i = 0, _len2 = sprites.length; i < _len2; i++) {
            sprite = sprites[i];
            sprites[i] = sprite = $TC.chart.change_type(sprite, type);
            $(sprite.canvas).addClass('ui-selected');
            _results.push(sprite.update());
          }
          return _results;
        });
        if (init_sel) {
          $label.val(sprites[0].opts.label);
        }
        _add_handler('label', $label, 'keyup', function() {
          var sprite, _j, _len2, _results;
          _results = [];
          for (_j = 0, _len2 = sprites.length; _j < _len2; _j++) {
            sprite = sprites[_j];
            sprite.opts.label = this.value;
            _results.push(sprite.update());
          }
          return _results;
        });
        last_rotation = sprites[0].opts.rotation;
        _add_handler('rotation', $rots, 'vclick', function(e) {
          var sprite, _j, _len2;
          for (_j = 0, _len2 = sprites.length; _j < _len2; _j++) {
            sprite = sprites[_j];
            switch (e.currentTarget.hash) {
              case '#left':
                sprite.rotate(-90);
                break;
              case '#right':
                sprite.rotate(90);
            }
            sprite.update();
          }
          last_rotation = sprites[0].opts.rotation;
          return false;
        });
        $del.button('enable');
        return _add_handler('delete', $del, 'vclick', function(e) {
          var sprite, _j, _len2;
          for (_j = 0, _len2 = sprites.length; _j < _len2; _j++) {
            sprite = sprites[_j];
            $TC.chart.remove(sprite);
          }
          return false;
        });
      }).bind('scaled_selectableunselected', _clear_selection);
      $TC.chart.bind('remove', _clear_selection);
      if (!$TC.chart.editable) {
        $menu.hide();
      }
      $TC.chart.bind('locked', function() {
        return $menu.hide();
      });
      return $TC.chart.bind('unlocked', function() {
        return $menu.show();
      });
    });
  });
}).call(this);
