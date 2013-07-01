{puts,print,inspect}  = require("util")
async                 = require('async')

class Connection

  constructor: (@pool, @schema) ->

  query: (sql..., queryDone) ->
    # logger.info sql
    client = null
    result = null
    sqlErr = null
    async.series(
      [
        (done) =>
          @pool.acquire (err, _client) ->
            client = _client
            done(err)
        (done) => client.query "SET search_path TO '#{@schema}'", done
        (done) =>
          client.query sql..., (_sqlErr, _result) ->
            # logger.error inspect _sqlErr if _sqlErr
            result = _result
            sqlErr = _sqlErr
            done()
        (done) =>
          @pool.release(client)
          done()
      ]
      (err) -> queryDone(err || sqlErr, result)
    )

module.exports = Connection
