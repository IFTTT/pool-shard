{puts, inspect} = require('util')
test_helper     = require('./test_helper')
ps              = require('../lib')

describe 'ConnectionCollection', ->

  before (done) ->
    @config =
      shards: 4
      nodes: [{
        url: 'tcp://postgres:@localhost/pool_shard_test1'
        shard:
          min: 1
          max: 2
        pool_size: 8
        idle_timeout_millis: 30000
      },{
        url: 'tcp://postgres:@localhost/pool_shard_test2'
        shard:
          min: 3
          max: 4
        pool_size: 8
        idle_timeout_millis: 30000
      }]
    
    done()

  beforeEach (done) ->
    @collection = new ps.ConnectionCollection(@config)
    done()

  after ->

  it 'should be a ConnectionCollection', (done) ->
    @collection.should.be.an.instanceOf(ps.ConnectionCollection)
    done()

  it 'should give connections to different db pools & schemas for different shardKeys', (done) ->
    connectionAlpha = @collection.connectionFor(1)
    connectionBeta  = @collection.connectionFor(4)
    poolAlpha = connectionAlpha.pool
    poolBeta  = connectionBeta.pool
    poolAlpha.should.not.equal(poolBeta)
    schemaAlpha = connectionAlpha.schema
    schemaBeta  = connectionBeta.schema
    schemaAlpha.should.not.equal(schemaBeta)
    done()

  it 'should calculate database & schema using configured number & division of shards and the specified shardKey', (done) ->
    shardKeyDelta   = 35
    connectionDelta = @collection.connectionFor(shardKeyDelta)
    schemaDelta     = connectionDelta.schema
    poolDelta       = connectionDelta.pool
    schemaDelta.should.equal('shard_0003')
    poolDelta.should.equal(@collection.pools[@config.nodes[1].url])
    done()

  it 'should return Connection for specified database & schema', (done) ->
    databaseName  = 'pool_shard_test2'
    schemaName    = 'shard_0003'
    connection    = @collection.connectionForSchema(databaseName, schemaName)
    connection.schema.should.equal(schemaName)
    done()

  it 'should return MultiConnection for specified all databases & schemas', (done) ->
    multiConnection = @collection.connectionForAll()
    multiConnection.poolsAndShards.length.should.equal(@config.nodes.length)
    done()


