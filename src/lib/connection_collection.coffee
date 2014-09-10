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

  # We allow for an arbitrary timeout here, because the native PG client
  # requires a bit of time before the connection is truly closed, and there is
  # no callback to verify. This is a kind of race condition, but we need to
  # be able to hack around it, otherwise connections may emit uncaught error
  # events even after destroyAllConnections() has been called.
  destroyAllConnections: (args...) ->
    switch args.length
      when 1
        opts = {}
        done = args[0]
      when 2
        opts = args[0]
        done = args[1]
      else
        throw new Error("Invalid arguments!")

    async.each Object.keys(@pools), (poolKey, stepDone) =>
      pool = @pools[poolKey]
      pool.destroyAllNow stepDone
    , (err) ->
      setTimeout ->
        done err
      , opts.timeout || 100

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

  _schemaOfShard: (shardNumber) -> @constructor.defaultSchemaForShard(shardNumber)

  @defaultSchemaForShard: (shardNumber) ->
    zeroPaddedShardNumber = ("0000" + shardNumber).slice(-4)
    "shard_#{zeroPaddedShardNumber}"

  _databaseOfShard: (shardNumber) ->
    for _, node of @config.nodes when node.shard.min <= shardNumber <= node.shard.max
      return node.url

module.exports = ConnectionCollection
