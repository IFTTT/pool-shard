{puts, inspect} = require('util')
ps              = require('../lib')
test_helper     = require('./test_helper')
config          = test_helper.config

class ClientStub
  constructor: () ->
    @queries = []

  query: (sql..., cb) ->
    @queries = @queries.concat(sql)
    cb(null, {})

class PoolStub
  constructor: (@client) ->
    @acquireCount = 0
    @releaseCount = 0

  acquire: (cb) ->
    @acquireCount++
    cb null, @client

  release: (_client) ->
    @releaseCount++

describe 'Connection', ->

  beforeEach (done) ->
    @schema     = 'shard_1234'
    @client     = new ClientStub
    @pool       = new PoolStub(@client)
    @connection = new ps.Connection(@pool, @schema)
    done()

  it 'should be a Connection', (done) ->
    @connection.should.be.an.instanceOf(ps.Connection)
    done()

  it 'should set search path on client, then send sql query', (done) ->
    sql = "SELECT * FROM stuffs;"
    @connection.query sql, (err, result) =>
      @client.queries[0].should.match(/search_path/)
      @client.queries[0].should.include(@schema)
      @client.queries[1].should.equal(sql)
      done()

  it 'should acquire AND release client', (done) ->
    @connection.query "SELECT * FROM stuff;", (err, result) =>
      @pool.acquireCount.should.equal(1)
      @pool.releaseCount.should.equal(1)
      done()
