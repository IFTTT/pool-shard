async      = require('async')
Connection = require('./connection')

class MultiConnection

  constructor: (@poolsAndShards) ->

  query: (sql..., doneQuery) =>
    connections = []
    for [pool, schemas] in @poolsAndShards
      for schema in schemas
        connections.push new Connection pool, schema
    async.map connections, (connection, done) ->
      connection.query sql..., done
    , doneQuery

module.exports = MultiConnection
