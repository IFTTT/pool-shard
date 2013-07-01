exports.setup = () ->

exports.config = 
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
