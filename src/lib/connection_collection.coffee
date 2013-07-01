{puts,inspect}  = require("util")
pg              = require('pg').native
async           = require('async')
Pool            = require('generic-pool').Pool
Connection      = require('./connection')
MultiConnection = require('./multi_connection')

class ConnectionCollection
  defaults =
    pool_size: 8
    idle_timeout_millis: 30000

  constructor: (@config)->
    @pools = {}
    @config.nodes ||= []
    for node in @config.nodes
      @pools[node.url] = do (node) =>
        pool = new Pool
          name:   'pg'
          create: (connected) =>
            client = new pg.Client(node.url, ssl: node.ssl)
            # logger.info "psql connecting to #{node.url}"
            client.connect (err) ->
              # logger.error inspect err if err
              connected(err, client)
          destroy: (client) -> client.end()
          max: node.pool_size || defaults.pool_size
          idleTimeoutMillis: node.idle_timeout_millis || defaults.idle_timeout_millis
          log: false # can also be a function
        pool.url = node.url
        pool

  connectionFor: (shardKey) ->
    shardNumber  = @_calculateShard(shardKey)
    schemaName   = @_schemaOfShard(shardNumber)
    databaseName = @_databaseOfShard(shardNumber)
    @connectionForSchema(databaseName, schemaName)

  connectionForSchema: (databaseName, schemaName) ->
    pool = @_poolFor(databaseName)
    new Connection(pool, schemaName)

  connectionForAll: ->
    poolsAndShards = for {url, shard:{min,max}} in @config.nodes
      pool    = @_poolFor(url)
      schemas = (@_schemaOfShard(i) for i in [min..max])
      [pool, schemas]
    new MultiConnection(poolsAndShards)

  _poolFor: (databaseName) ->
    @pools[databaseName]

  _calculateShard: (shardKey) ->
    shardNumber = ((shardKey - 1) % @config.shards) + 1
    throw "No shard key provided!" if isNaN(shardNumber)
    shardNumber

  _schemaOfShard: (shardNumber) ->
    zeroPaddedShardNumber = ("0000" + shardNumber).slice(-4)
    "shard_#{zeroPaddedShardNumber}"

  _databaseOfShard: (shardNumber) ->
    for _, node of @config.nodes when node.shard.min <= shardNumber <= node.shard.max
      return node.url

module.exports = ConnectionCollection
