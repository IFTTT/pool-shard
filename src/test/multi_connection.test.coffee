{puts, inspect} = require('util')
ps              = require('../lib')
test_helper     = require('./test_helper')

describe 'MultiConnection', ->

  beforeEach (done) ->
    @clientAlpha      = new test_helper.ClientStub
    @clientBeta       = new test_helper.ClientStub
    @poolAlpha        = new test_helper.PoolStub(@clientAlpha)
    @poolBeta         = new test_helper.PoolStub(@clientBeta)
    @schemaAlpha1     = 'shard_0001'
    @schemaAlpha2     = 'shard_0002'
    @schemaBeta3      = 'shard_0003'
    @schemaBeta4      = 'shard_0004'
    @poolsAndShards   = [
      [@poolAlpha, [@schemaAlpha1, @schemaAlpha2]],
      [@poolBeta,  [@schemaBeta3,  @schemaBeta4 ]],
    ]
    @multiConnection  = new ps.MultiConnection(@poolsAndShards)
    done()

  it 'should be a MultiConnection', (done) ->
    @multiConnection.should.be.an.instanceOf(ps.MultiConnection)
    done()

  it 'should send sql query to all pools and shards', (done) ->
    sql = "SELECT * FROM stuffs;"
    @multiConnection.query sql, (err, result) =>
      @clientAlpha.queries[0].should.include(@schemaAlpha1)
      @clientAlpha.queries[1].should.equal(sql)
      @clientAlpha.queries[2].should.include(@schemaAlpha2)
      @clientAlpha.queries[3].should.equal(sql)
      @clientBeta.queries[0].should.include(@schemaBeta3)
      @clientBeta.queries[1].should.equal(sql)
      @clientBeta.queries[2].should.include(@schemaBeta4)
      @clientBeta.queries[3].should.equal(sql)
      done()
