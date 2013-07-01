{puts, inspect} = require('util')
test_helper     = require('./test_helper')
ps              = require('../lib')

describe 'ConnectionCollection', ->

  before (done) ->
    @config =
      nodes: [{
        url: 'tcp://postgres:@localhost/diary_test1'
        shard:
          min: 1
          max: 2
        pool_size: 8
        idle_timeout_millis: 30000
      },{
        url: 'tcp://postgres:@localhost/diary_test2'
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
