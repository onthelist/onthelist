(function() {
  var ElapsedTimeList, IsotopeList, QueueList, TimeList;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __slice = Array.prototype.slice;
  IsotopeList = (function() {
    function IsotopeList(elem, opts) {
      this.elem = elem;
      this.opts = opts;
      this.dynamics_added = false;
    }
    IsotopeList.prototype._height_changed = function() {
      return $(this.elem).trigger('heightChange');
    };
    IsotopeList.prototype.add_dynamics = function() {
      var $elem, sort_fields, use_transforms, _ref, _ref2, _ref3, _ref4;
      this.dynamics_added = true;
      use_transforms = function() {
        var ua;
        ua = navigator.userAgent;
        if (/mobile/i.test(ua)) {
          return true;
        }
        return false;
      };
      sort_fields = {
        remaining: function(el) {
          var $time, elapsed, target;
          $time = $('time', el);
          elapsed = parseInt($time.attr('data-minutes'));
          target = parseInt($time.attr('data-target'));
          return target - elapsed;
        },
        elapsed: function($el) {
          return parseInt($el.find('time').attr('data-minutes'));
        },
        lname: function($el) {
          var name;
          name = $el.find('[data-key=name]').text();
          if (name.indexOf(' ') === -1) {
            return name;
          }
          return name.substring(name.indexOf(' ') + 1);
        },
        size: function($el) {
          var size;
          size = $el.find('[data-key=size]').text();
          return parseInt(size);
        }
      };
      $elem = $(this.elem);
      $elem.isotope({
        itemSelector: 'li:not(.ui-li-divider)',
        layoutMode: 'sectionList',
        groupBy: (_ref = (_ref2 = this.groupBy) != null ? _ref2 : this.opts.group) != null ? _ref : 'lname',
        transformsEnabled: use_transforms(),
        getSortData: sort_fields,
        sortBy: (_ref3 = (_ref4 = this.sortBy) != null ? _ref4 : this.opts.sort) != null ? _ref3 : 'remaining',
        filter: ':not(.ui-screen-hidden)',
        animationOptions: {
          complete: __bind(function() {
            return this._height_changed();
          }, this)
        },
        getGroupData: {
          lname: {
            num: 3,
            vertDistribute: true,
            sectionBounds: ['A', 'Z'],
            parse: function(el) {
              var lname;
              lname = sort_fields.lname($(el));
              return lname.substring(0, 1).toUpperCase();
            }
          },
          size: {
            sectionBounds: [1, 3, 5],
            unboundedRight: true,
            parse: function(el) {
              return sort_fields.size($(el));
            },
            labelMaker: function(type, left, right) {
              switch (type) {
                case 'INF':
                  return "Parties of " + left + " or more";
                  break;
                case 'range':
                  return "Parties of " + left + " to " + right;
                  break;
                case 'single':
                  return "Parties of " + left;
              }
            }
          },
          remaining: {
            sectionBounds: [-30, 30],
            unboundedLeft: true,
            unboundedRight: true,
            labelMaker: function(type, left, right) {
              var _convert;
              _convert = function(v) {
                if (v >= 0) {
                  return "" + v + " Min Remaining";
                } else {
                  return "" + (Math.abs(v)) + " Min Over";
                }
              };
              switch (type) {
                case '-INF':
                  return "More Than " + (_convert(left));
                  break;
                case 'INF':
                  return "More Than " + (_convert(left));
                  break;
                case 'range':
                  return "" + (_convert(left)) + " to " + (_convert(right));
                  break;
                case 'single':
                  return _convert(left);
              }
            },
            parse: function(el) {
              return sort_fields.remaining(el);
            }
          },
          elapsed: {
            sectionBounds: [0, 60],
            unboundedRight: true,
            labelMaker: function(type, left, right) {
              var _convert;
              _convert = function(v) {
                return "" + v + " Min";
              };
              switch (type) {
                case '-INF':
                  return "More Than " + (_convert(left));
                  break;
                case 'INF':
                  return "More Than " + (_convert(left));
                  break;
                case 'range':
                  return "" + (_convert(left)) + " to " + (_convert(right));
                  break;
                case 'single':
                  return _convert(left);
              }
            },
            parse: function(el) {
              return sort_fields.elapsed($(el));
            }
          }
        }
      });
      $elem.bind('webkitTransitionEnd transitionend oTransitionEnd', __bind(function(e) {
        if (e.target === $elem[0]) {
          return this._height_changed();
        }
      }, this));
      $elem.bind('filter', __bind(function() {
        return this.refresh();
      }, this));
      $elem.bind('filterSubmit', __bind(function() {
        var $items;
        $items = $elem.find('.isotope-item:not(.ui-screen-hidden)');
        if ($items.length !== 1) {
          return;
        }
        return $items.find('a').trigger('vclick');
      }, this));
      return $elem.isotope('reLayout');
    };
    IsotopeList.prototype.refresh = function() {
      var iso;
      if (this.dynamics_added) {
        $(this.elem).isotope('reloadItems');
        iso = $(this.elem).data('isotope');
        return iso._init();
      }
    };
    IsotopeList.prototype.sort = function(key) {
      this.sortBy = key;
      return $(this.elem).isotope({
        sortBy: key
      });
    };
    IsotopeList.prototype.group = function(key) {
      this.groupBy = key;
      return $(this.elem).isotope({
        groupBy: key
      });
    };
    IsotopeList.prototype.remove = function($elems) {
      return $(this.elem).isotope('remove', $elems);
    };
    return IsotopeList;
  })();
  TimeList = (function() {
    __extends(TimeList, IsotopeList);
    function TimeList(elem, opts) {
      this.elem = elem;
      this.opts = opts;
      TimeList.__super__.constructor.apply(this, arguments);
      $$(this.elem).time_list = this;
    }
    TimeList.prototype.refresh = function() {
      if (this.elem.jqmData('listview')) {
        this.elem.listview('refresh');
      }
      return TimeList.__super__.refresh.apply(this, arguments);
    };
    return TimeList;
  })();
  ElapsedTimeList = (function() {
    __extends(ElapsedTimeList, TimeList);
    function ElapsedTimeList(elem, opts) {
      var self;
      this.elem = elem;
      this.opts = opts;
      ElapsedTimeList.__super__.constructor.apply(this, arguments);
      self = this;
      setInterval(function() {
        return self.update();
      }, 60000);
    }
    ElapsedTimeList.prototype.insert = function(elem) {
      $('time', elem).time();
      $(this.elem).append(elem);
      return this.refresh();
    };
    ElapsedTimeList.prototype.update = function() {
      var self;
      self = this;
      this.elem.children('li[data-role=list-divider]').each(function(i, elem) {
        var last, start;
        elem = $(elem);
        start = parseInt(elem.attr('data-start'));
        if (start === NaN) {
          return;
        }
        last = null;
        elem.prevAll('li').each(function(j, el) {
          var time;
          time = $('time', el);
          if (!time) {
            return;
          }
          if (parseInt(time.attr('data-minutes')) >= start) {
            return last = el;
          } else {
            return false;
          }
        });
        if (last) {
          elem.detach();
          return $(last).before(elem);
        }
      });
      return this.refresh();
    };
    return ElapsedTimeList;
  })();
  QueueList = (function() {
    __extends(QueueList, ElapsedTimeList);
    function QueueList() {
      QueueList.__super__.constructor.apply(this, arguments);
    }
    QueueList.prototype.add_sections = function() {
      var li;
      QueueList.__super__.add_sections.apply(this, arguments);
      li = $('<li></li>');
      li.attr('data-role', 'list-divider');
      li.attr('data-theme', 'a');
      li.attr('data-place', 'false');
      li.text('Upcoming Reservations');
      this.elem.append(li);
      return this.refresh();
    };
    return QueueList;
  })();
  $.fn.queueList = function() {
    var action, args, _ref;
    action = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    if (!($$(this).time_list != null)) {
      return new QueueList(this, action);
    }
    return (_ref = $$(this).time_list[action]).call.apply(_ref, [this].concat(__slice.call(args)));
  };
}).call(this);
