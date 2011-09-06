(function() {
  var __hasProp = Object.prototype.hasOwnProperty, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  $.extend($.Isotope.prototype, {
    _getGroups: function(num_cols, guess_height) {
      var group, name, _ref, _ref2, _results;
      this.groupData = (_ref = this.options.getGroupData) != null ? _ref : {};
      this.groupBy = this.options.groupBy;
      _ref2 = this.groupData;
      _results = [];
      for (name in _ref2) {
        if (!__hasProp.call(_ref2, name)) continue;
        group = _ref2[name];
        _results.push(this._buildSection(group, num_cols, guess_height));
      }
      return _results;
    },
    _defaultSectionLabeler: function(type, left, right) {
      switch (type) {
        case '-INF':
          return "Less Than " + left;
          break;
        case 'INF':
          return "More Than " + left;
          break;
        case 'range':
          return "" + left + " - " + right;
          break;
        case 'single':
          return left;
      }
    },
    _buildSection: function(group, num_cols, guess_height) {
      var bound, def_parse, e_bounds, en_bound, func, height, i, label, lbl_maker, map, num, pages, s_bounds, section, sections, st_bound, start, _len, _ref, _ref2, _ref3;
      lbl_maker = (_ref = group.labelMaker) != null ? _ref : this._defaultSectionLabeler;
      if ((_ref2 = group.num) == null) {
        group.num = 4;
      }
      if (group.sectionBounds != null) {
        if (group.sectionBounds.length === 2) {
          if (!group.allowPartialRows && group.num > num_cols) {
            num = num_cols;
            while (num + ((num_cols - 1) / 2) < group.num) {
              num += num_cols;
            }
          } else {
            num = group.num;
          }
          if (group.vertDistribute && num_cols === 1) {
            while (num < 30) {
              height = guess_height(num);
              pages = this._estimateNumPages(height);
              if (pages * 1.5 < num) {
                break;
              }
              num += 1;
            }
          }
          if (group.unboundedRight) {
            num -= 1;
          }
          s_bounds = this._listBounds(group.sectionBounds, num, group);
        } else {
          s_bounds = group.sectionBounds;
        }
        sections = [];
        e_bounds = [];
        for (i = 0, _len = s_bounds.length; i < _len; i++) {
          bound = s_bounds[i];
          start = bound;
          if (group.unboundedLeft && i === 0) {
            label = lbl_maker('-INF', bound);
            start = '-';
          } else if (group.unboundedRight && i === (s_bounds.length - 1)) {
            label = lbl_maker('INF', bound);
          } else if (i === (s_bounds.length - 1)) {
            continue;
          } else {
            st_bound = bound;
            en_bound = this._shiftBound(s_bounds[i + 1], -1);
            if (st_bound === en_bound) {
              label = lbl_maker('single', st_bound);
            } else {
              label = lbl_maker('range', st_bound, en_bound);
            }
          }
          e_bounds.push(en_bound);
          section = {
            label: label,
            attrs: {
              'data-start': start
            }
          };
          sections.push(section);
        }
        def_parse = function(el) {
          return parseInt(el.text());
        };
        func = (_ref3 = group.parse) != null ? _ref3 : def_parse;
        map = function(el, $sections) {
          var last, val;
          val = func(el);
          last = 0;
          $.each($sections, function(i, $sec) {
            start = $sec.attr('data-start');
            if (start === '-') {
              return;
            }
            if (typeof val !== 'string') {
              start = parseInt(start);
            }
            if (start > val) {
              return false;
            }
            return last = i;
          });
          return last;
        };
        group.sections = sections;
        return group.map = map;
      }
    },
    _shiftBound: function(bound, i) {
      var is_char;
      if (i == null) {
        i = 1;
      }
      is_char = typeof bound === 'string';
      if (is_char) {
        bound = bound.charCodeAt(0);
      }
      bound += i;
      if (is_char) {
        bound = String.fromCharCode(bound);
      }
      return bound;
    },
    _listBounds: function(bounds, num, group) {
      var b, i, incr, is_char, o, out;
      is_char = typeof bounds[0] === 'string';
      if (is_char) {
        bounds = (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = bounds.length; _i < _len; _i++) {
            b = bounds[_i];
            _results.push(b.charCodeAt(0));
          }
          return _results;
        })();
      }
      this.range = (bounds[1] - bounds[0]) + 1;
      num = Math.min(this.range + 1, num);
      incr = this.range / num;
      b = bounds[0];
      out = [];
      for (i = 0; 0 <= num ? i < num : i > num; 0 <= num ? i++ : i--) {
        out.push(Math.floor(b + .5));
        b += incr;
      }
      out.push(bounds[1] + 1);
      if (group.unboundedLeft) {
        out[1] = out[0];
      }
      if (is_char) {
        out = (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = out.length; _i < _len; _i++) {
            o = out[_i];
            _results.push(String.fromCharCode(o));
          }
          return _results;
        })();
      }
      return out;
    },
    _createGroups: function() {
      var $el, $last, group, i, name, val, _len, _ref, _ref2, _results;
      this.groups = this.groupData[this.groupBy];
      this.sections = [];
      $last = null;
      _ref = this.groups.sections;
      _results = [];
      for (i = 0, _len = _ref.length; i < _len; i++) {
        group = _ref[i];
        $el = $('<li></li>');
        $el.addClass('ui-li ui-li-divider ui-bar-b section-header');
        $el.css('top', 0).css('left', 0).css('position', 'absolute');
        $el.attr('data-role', 'list-divider');
        $el.attr('data-index', i);
        if (group.attrs != null) {
          _ref2 = group.attrs;
          for (name in _ref2) {
            if (!__hasProp.call(_ref2, name)) continue;
            val = _ref2[name];
            $el.attr(name, val);
          }
        }
        $el.html("<span class='ui-li-divider-inner'>" + group.label + "</span>");
        if ($last != null) {
          $last.after($el);
        } else {
          this.element.prepend($el);
        }
        $last = $el;
        _results.push(this.sections.push({
          $el: $el,
          opts: group
        }));
      }
      return _results;
    },
    _findSection: function(el) {
      var $sections, i, s;
      if (el.getAttribute('data-index') != null) {
        return parseInt(el.getAttribute('data-index'));
      }
      $sections = (function() {
        var _i, _len, _ref, _results;
        _ref = this.sections;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          s = _ref[_i];
          _results.push(s.$el);
        }
        return _results;
      }).call(this);
      i = this.groups.map(el, $sections);
      if (i != null) {
        return i;
      }
      throw "Invalid Section";
    },
    _estimateNumPages: function(height) {
      var page_height, page_size;
      page_size = $UI.get_page_space($('.ui-page-active'));
      page_height = page_size[1] - 30;
      return height / page_height;
    }
  });
  $.extend($.Isotope.prototype, {
    _sectionListGetDims: function() {
      var _ref, _ref2;
      this.min_col_width = (_ref = this.sectionList.minColumnWidth) != null ? _ref : 300;
      this.sectionList.colSpacing = (_ref2 = this.sectionList.columnSpacing) != null ? _ref2 : 1;
      this.sectionList.numCols = this._sectionListNumCols();
      return this.sectionList.colWidth = (this.width - this.sectionList.colSpacing * (this.sectionList.numCols - 1)) / this.sectionList.numCols;
    },
    _sectionListNumCols: function(limit) {
      var num;
      if (limit == null) {
        limit = true;
      }
      this.width = this.element.width();
      num = Math.floor(this.width / this.min_col_width) || 1;
      if (limit && this.sections && this.sections.length) {
        num = Math.min(this.sections.length, num);
      }
      return num;
    },
    _sectionListEstimateHeight: function(num_elems, num_cols, num_sections) {
      var DIVIDER_HEIGHT, ELEMENT_HEIGHT, v_elem_cnt, v_sec_cnt;
      DIVIDER_HEIGHT = 33;
      ELEMENT_HEIGHT = 46;
      v_elem_cnt = num_elems / num_cols;
      v_sec_cnt = num_sections / num_cols;
      return ELEMENT_HEIGHT * v_elem_cnt + DIVIDER_HEIGHT * v_sec_cnt;
    },
    _sectionListMap: function($elems) {
      var section, self, _i, _len, _ref;
      self = this;
      this.sectionList.members = [];
      _ref = this.sections;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        section = _ref[_i];
        this.sectionList.members.push([]);
      }
      return $elems.each(function() {
        var index;
        index = self._findSection(this);
        return self.sectionList.members[index].push(this);
      });
    },
    _sectionListGetPos: function() {
      var $header, col, el, height, index, lst, max_row_height, row, y, _i, _len, _len2, _ref, _results;
      this.sectionList.coords = [];
      col = row = 0;
      max_row_height = y = 0;
      _ref = this.sectionList.members;
      _results = [];
      for (index = 0, _len = _ref.length; index < _len; index++) {
        lst = _ref[index];
        if (col >= this.sectionList.numCols) {
          col = 0;
          row++;
          y += max_row_height;
          max_row_height = 0;
        }
        $header = this.sections[index].$el;
        height = $header.outerHeight();
        if (lst != null) {
          for (_i = 0, _len2 = lst.length; _i < _len2; _i++) {
            el = lst[_i];
            height += $(el).outerHeight();
          }
        }
        if (height > max_row_height) {
          max_row_height = height;
        }
        this.sectionList.coords[index] = {
          x: col * (this.sectionList.colWidth + this.sectionList.colSpacing),
          y: y,
          height: height
        };
        _results.push(col++);
      }
      return _results;
    },
    _sectionListWidthPercentage: function(px) {
      var view_width;
      if (this.options.transformsEnabled) {
        return px;
      }
      view_width = this.element.width();
      return 100 * (px / view_width) + '%';
    },
    _sectionListSetWidth: function($el) {
      var width;
      width = this.sectionList.colWidth;
      width -= parseFloat($el.css('padding-left'));
      width -= parseFloat($el.css('padding-right'));
      return $el.width(this._sectionListWidthPercentage(width));
    },
    _sectionListPlace: function() {
      var $el, $header, coords, el, index, lst, x, y, _len, _ref, _results;
      _ref = this.sectionList.members;
      _results = [];
      for (index = 0, _len = _ref.length; index < _len; index++) {
        lst = _ref[index];
        coords = this.sectionList.coords[index];
        $header = this.sections[index].$el;
        this._pushPosition($header, this._sectionListWidthPercentage(coords.x), coords.y);
        this._sectionListSetWidth($header);
        if (!(lst != null)) {
          continue;
        }
        y = coords.y + $header.outerHeight();
        x = coords.x;
        _results.push((function() {
          var _i, _len2, _results2;
          _results2 = [];
          for (_i = 0, _len2 = lst.length; _i < _len2; _i++) {
            el = lst[_i];
            $el = $(el);
            this._sectionListSetWidth($el);
            this._pushPosition($el, this._sectionListWidthPercentage(x), y);
            _results2.push(y += $el.outerHeight());
          }
          return _results2;
        }).call(this));
      }
      return _results;
    },
    _sectionListReset: function() {
      this.sectionList = {};
      return $(this.element).find('.section-header').remove();
    },
    _sectionListLayout: function($elems) {
      var guess_height, num_cols;
      num_cols = this._sectionListNumCols(false);
      guess_height = __bind(function(num_sections) {
        var cols;
        cols = Math.min(num_cols, num_sections);
        return this._sectionListEstimateHeight($elems.length, cols, num_sections);
      }, this);
      this._getGroups(num_cols, guess_height);
      this._createGroups();
      this._sectionListGetDims();
      this._sectionListMap($elems);
      this._sectionListGetPos();
      return this._sectionListPlace();
    },
    _sectionListGetContainerSize: function() {
      var coords, i, max_height, section, _i, _len, _len2, _ref, _ref2;
      max_height = 0;
      _ref = this.sections;
      for (i = 0, _len = _ref.length; i < _len; i++) {
        section = _ref[i];
        if (i % this.sectionList.numCols === 0) {
          max_height += section.$el.outerHeight();
        }
      }
      _ref2 = this.sectionList.coords;
      for (_i = 0, _len2 = _ref2.length; _i < _len2; _i++) {
        coords = _ref2[_i];
        max_height = Math.max(max_height, coords.y + coords.height);
      }
      return {
        height: max_height
      };
    },
    _sectionListResizeChanged: function() {
      return this.options.transformsEnabled || this.sectionList.numCols !== this._sectionListNumCols();
    }
  });
}).call(this);
