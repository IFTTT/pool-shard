// Generated by CoffeeScript 1.6.3
(function() {
  var ClientStub, PoolStub,
    __slice = [].slice;

  exports.setup = function() {};

  PoolStub = (function() {
    function PoolStub(client) {
      this.client = client;
      this.acquireCount = 0;
      this.releaseCount = 0;
    }

    PoolStub.prototype.acquire = function(cb) {
      this.acquireCount++;
      return cb(null, this.client);
    };

    PoolStub.prototype.release = function(_client) {
      return this.releaseCount++;
    };

    return PoolStub;

  })();

  ClientStub = (function() {
    function ClientStub() {
      this.queries = [];
    }

    ClientStub.prototype.query = function() {
      var cb, sql, _i;
      sql = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), cb = arguments[_i++];
      this.queries = this.queries.concat(sql);
      return cb(null, {});
    };

    return ClientStub;

  })();

  exports.PoolStub = PoolStub;

  exports.ClientStub = ClientStub;

}).call(this);
