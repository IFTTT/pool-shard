// Generated by CoffeeScript 1.6.3
(function() {
  var config, inspect, ps, puts, test_helper, _ref;

  _ref = require('util'), puts = _ref.puts, inspect = _ref.inspect;

  ps = require('../lib');

  test_helper = require('./test_helper');

  config = test_helper.config;

  describe('ConnectionCollection', function() {
    beforeEach(function(done) {
      this.config = {
        shards: 4,
        nodes: [
          {
            url: 'tcp://postgres:@localhost/pool_shard_test1',
            shard: {
              min: 1,
              max: 2
            },
            pool_size: 8,
            idle_timeout_millis: 30000
          }, {
            url: 'tcp://postgres:@localhost/pool_shard_test2',
            shard: {
              min: 3,
              max: 4
            },
            pool_size: 8,
            idle_timeout_millis: 30000
          }
        ]
      };
      this.collection = new ps.ConnectionCollection(this.config);
      return done();
    });
    it('should be a ConnectionCollection', function(done) {
      this.collection.should.be.an.instanceOf(ps.ConnectionCollection);
      return done();
    });
    it('should give connections to different db pools & schemas for different shardKeys', function(done) {
      var connectionAlpha, connectionBeta, poolAlpha, poolBeta, schemaAlpha, schemaBeta;
      connectionAlpha = this.collection.connectionFor(1);
      connectionBeta = this.collection.connectionFor(4);
      poolAlpha = connectionAlpha.pool;
      poolBeta = connectionBeta.pool;
      poolAlpha.should.not.equal(poolBeta);
      schemaAlpha = connectionAlpha.schema;
      schemaBeta = connectionBeta.schema;
      schemaAlpha.should.not.equal(schemaBeta);
      return done();
    });
    it('should calculate database & schema using configured number & division of shards and the specified shardKey', function(done) {
      var connectionDelta, poolDelta, schemaDelta, shardKeyDelta;
      shardKeyDelta = 35;
      connectionDelta = this.collection.connectionFor(shardKeyDelta);
      schemaDelta = connectionDelta.schema;
      poolDelta = connectionDelta.pool;
      schemaDelta.should.equal('shard_0003');
      poolDelta.should.equal(this.collection.pools[this.config.nodes[1].url]);
      return done();
    });
    it('should return Connection for specified database & schema', function(done) {
      var connection, databaseName, schemaName;
      databaseName = 'pool_shard_test2';
      schemaName = 'shard_0003';
      connection = this.collection.connectionForSchema(databaseName, schemaName);
      connection.schema.should.equal(schemaName);
      return done();
    });
    return it('should return MultiConnection for specified all databases & schemas', function(done) {
      var multiConnection;
      multiConnection = this.collection.connectionForAll();
      multiConnection.poolsAndShards.length.should.equal(this.config.nodes.length);
      return done();
    });
  });

}).call(this);
