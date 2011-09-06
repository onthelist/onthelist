(function() {
  var Action, AlertAction, _ref;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __slice = Array.prototype.slice;
  if ((_ref = window.$IO) == null) {
    window.$IO = {};
  }
  Action = (function() {
    Action.prototype.status_on = {
      progress: false,
      success: false,
      error: true
    };
    Action.prototype.auto_retry = true;
    function Action() {
      this.attempts = 0;
      this.status = new $UI.Status;
    }
    Action.prototype.success = function(resp) {
      var status;
      if (!resp || !resp.ok) {
        this.error(resp);
        return;
      }
      this.attempts = 0;
      status = {
        msg: "" + this.noun + " " + this.post_verb,
        style: 'success'
      };
      if (this.status_on.success) {
        return this.status.update(status);
      } else {
        return this.status.hide();
      }
    };
    Action.prototype.error = function(resp, status, msg) {
      var delay, timeout;
      if (this.attempts < 2 && this.elapsed < 3) {
        setTimeout(__bind(function() {
          this.attempts++;
          return this._do();
        }, this), 2000);
        return;
      }
      status = {
        msg: "Error " + this.adverb + " " + this.noun,
        style: 'error',
        ttl: 0,
        actions: {
          retry: __bind(function() {
            return this["do"]();
          }, this)
        }
      };
      this._add_cancel(status);
      if (this.status_on.error) {
        this.status.update(status);
      } else {
        this.status.hide();
      }
      if (this.auto_retry) {
        delay = Math.pow(2, this.attempts - 1) * 5;
        this.status.update_action('retry', {
          status: "Retrying in <time data-target='" + (delay / 60) + "' datetime='" + ((new Date).toISOString()) + "' data-format='remaining'></time>",
          text: 'Retry Now'
        });
        timeout = setTimeout(__bind(function() {
          this.status.update_action('retry', {
            status: null,
            link: false,
            text: 'Retrying Now'
          });
          this.attempts++;
          return this._do();
        }, this), delay * 1000);
        return this.status.update_action('cancel', {
          text: 'Cancel',
          func: __bind(function() {
            clearTimeout(timeout);
            return this.status.hide();
          }, this)
        });
      }
    };
    Action.prototype._add_cancel = function(status) {
      var _ref2;
      if (this.cancel != null) {
        if ((_ref2 = status.actions) == null) {
          status.actions = {};
        }
        return status.actions.cancel = {
          func: __bind(function() {
            return this.cancel();
          }, this),
          text: 'Cancel',
          style: 'cancel'
        };
      }
    };
    Action.prototype["do"] = function() {
      var start, status;
      this.attempts++;
      start = new Date;
      this.__defineGetter__('elapsed', function() {
        return (new Date).secondsSince(start);
      });
      status = {
        msg: "" + this.adverb + " " + this.noun
      };
      this._add_cancel(status);
      if (this.status_on.progress) {
        this.status.update(status);
      } else {
        this.status.hide();
      }
      return this._do();
    };
    return Action;
  })();
  AlertAction = (function() {
    __extends(AlertAction, Action);
    AlertAction.prototype.adverb = "Alerting";
    AlertAction.prototype.post_verb = "Alerted";
    AlertAction.prototype.noun = "Guest";
    function AlertAction(data, opts) {
      var name, val;
      this.data = data;
      if (opts == null) {
        opts = {};
      }
      AlertAction.__super__.constructor.apply(this, arguments);
      this.noun = this.data.name;
      for (name in this) {
        val = this[name];
        if (!(opts[name] != null)) {
          continue;
        }
        if (Object.isObject(val)) {
          this[name] = $.extend(true, {}, val, opts[name]);
        } else {
          this[name] = opts[name];
        }
      }
    }
    AlertAction.prototype.success = function(resp) {
      var _base, _ref2;
      AlertAction.__super__.success.apply(this, arguments);
      if ((_ref2 = (_base = this.data.times).alerts) == null) {
        _base.alerts = [];
      }
      this.data.times.alerts.push(new Date);
      this.data.remove_status('alerting');
      this.data.add_status('alerted');
      return this.data.save(false);
    };
    AlertAction.prototype.error = function() {
      this.data.remove_status('alerting');
      this.data.save(false);
      return AlertAction.__super__.error.apply(this, arguments);
    };
    AlertAction.prototype.cancel = function() {
      this.data.remove_status('alerting');
      return this.data.save(false);
    };
    AlertAction.prototype._do = function() {
      var opts;
      this.data.add_status('alerting');
      this.data.save(false);
      opts = {
        success: __bind(function() {
          var args;
          args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          return this.success.apply(this, args);
        }, this),
        error: __bind(function() {
          var args;
          args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          return this.error.apply(this, args);
        }, this)
      };
      switch (this.data.alert_method) {
        case 'sms':
          return $M.send_sms(this.data.phone, 'Your table is ready! Please visit the host stand to be seated.', opts);
        case 'call':
          return $M.make_call(this.data.phone, 'Your table is ready! Please visit the host stand to be seated.', opts);
        case 'wait':
          alert("Please call waiting guest " + this.data.name);
          return this.success({
            ok: true
          });
        case 'page':
          alert("Please page #" + this.data.pager_number);
          return this.success({
            ok: true
          });
      }
    };
    return AlertAction;
  })();
  $IO.alert = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return ((function(func, args, ctor) {
      ctor.prototype = func.prototype;
      var child = new ctor, result = func.apply(child, args);
      return typeof result === "object" ? result : child;
    })(AlertAction, args, function() {}))["do"]();
  };
}).call(this);
