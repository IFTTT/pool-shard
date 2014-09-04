{puts, inspect} = require('util')
ps              = require('../lib')
test_helper     = require('./test_helper')
config          = test_helper.config

describe 'ConnectionCollection', ->

  beforeEach (done) ->
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
    @collection = new ps.ConnectionCollection(@config)
    done()

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

  describe '#createDatabases', ->

    beforeEach ->
      @adminClients = []

      # Stub out adminClient method
      @adminClientOld = ps.ConnectionCollection.adminClient
      ps.ConnectionCollection.adminClient = (opts) =>
        client = new test_helper.ClientStub
        @adminClients.push client
        client

    afterEach ->
      # Unstub adminClient method
      ps.ConnectionCollection.adminClient = @adminClientOld

    it 'should create one database for each one specified in the config', (done) ->
      @collection.createDatabases (err) =>
        throw err if err

        @adminClients.length.should == 2

        @adminClients[0].queries.length.should == 1
        @adminClients[0].queries[0].should == 'CREATE DATABASE pool_shard_test1'

        @adminClients[1].queries.length.should == 1
        @adminClients[1].queries[0].should == 'CREATE DATABASE pool_shard_test2'

        done()

  describe '#createDatabases', ->

    beforeEach ->
      @stubClients = []
      @stubPools = []

      # Stub out the connection pools
      for databaseName, _unused of @collection.pools
        client = new test_helper.ClientStub
        pool = new test_helper.PoolStub(client)

        @stubClients.push client
        @stubPools.push pool

        @collection.pools[databaseName] = pool

    it 'should create one schema for each one specified in the config', (done) ->
      @collection.createSchemas (err) =>
        throw err if err

        @stubClients.length.should == 2
        @stubPools.length.should == 2

        @stubClients[0].queries.length.should == 2
        @stubClients[0].queries[0].should == 'CREATE SCHEMA shard_0001'
        @stubClients[0].queries[1].should == 'CREATE SCHEMA shard_0002'

        @stubClients[1].queries.length.should == 2
        @stubClients[1].queries[0].should == 'CREATE SCHEMA shard_0003'
        @stubClients[1].queries[1].should == 'CREATE SCHEMA shard_0004'

        done()