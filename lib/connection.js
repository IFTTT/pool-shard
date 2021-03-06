// Generated by CoffeeScript 1.8.0
(function() {
  var Connection, async, inspect, print, puts, _ref,
    __slice = [].slice;

  _ref = require("util"), puts = _ref.puts, print = _ref.print, inspect = _ref.inspect;

  async = require('async');

  Connection = (function() {
    function Connection(pool, schema) {
      this.pool = pool;
      this.schema = schema;
    }

    Connection.prototype.query = function() {
      var client, queryDone, result, sql, sqlErr, _i;
      sql = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), queryDone = arguments[_i++];
      client = null;
      result = null;
      sqlErr = null;
      return async.series([
        (function(_this) {
          return function(done) {
            return _this.pool.acquire(function(err, _client) {
              client = _client;
              return done(err);
            });
          };
        })(this), (function(_this) {
          return function(done) {
            return client.query("SET search_path TO '" + _this.schema + "'", done);
          };
        })(this), (function(_this) {
          return function(done) {
            return client.query.apply(client, __slice.call(sql).concat([function(_sqlErr, _result) {
              result = _result;
              sqlErr = _sqlErr;
              return done();
            }]));
          };
        })(this), (function(_this) {
          return function(done) {
            _this.pool.release(client);
            return done();
          };
        })(this)
      ], function(err) {
        return queryDone(err || sqlErr, result);
      });
    };

    return Connection;

  })();

  module.exports = Connection;

}).call(this);
