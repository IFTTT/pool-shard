exports.setup = () ->

class PoolStub
  constructor: (@client) ->
    @acquireCount = 0
    @releaseCount = 0

  acquire: (cb) ->
    @acquireCount++
    cb null, @client

  release: (_client) ->
    @releaseCount++

class ClientStub
  constructor: () ->
    @queries = []

  connect: (cb) ->
    cb()

  end: ->

  query: (sql..., cb) ->
    @queries = @queries.concat(sql)
    cb null, {}

exports.PoolStub    = PoolStub
exports.ClientStub  = ClientStub
