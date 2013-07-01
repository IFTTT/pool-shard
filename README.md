# pool-shard

Pools of sharded PostgreSQL database connections.

## Installation

    $ npm install git://github.com/promptworks/pool-shard.git#master

## Examples

```javascript
var ConnectionCollection = require('pool-shard').ConnectionCollection;
var collection = new ConnectionCollection({});
var connection = collection.connectionFor(123456);
connection.connect(function(err) {
  connection.query('SELECT NOW() AS "theTime"', function(err, result) {
    console.log(result.rows[0].theTime);
    //output: Tue Jan 15 2013 19:12:47 GMT-600 (CST)
  })
});
```

## Dependencies

1. npm
2. postgres
3. node-postgres

## Contributing

### Set Up

Install node, npm, postgres (on OSX with homebrew)

    $ brew update
    $ brew install node postgres

Clone copy of code repository

    $ cd path/to/workspace/
    $ git clone git@github.com:IFTTT/pool-shard.git
    $ cd pool-shard/

Install node module dependencies, create databases & shards, and run migrations for test databases

    $ make newb

### Running the tests

Run the tests to ensure everything works

    $ make test

### TODO

1. Inject logger
2. Inject pg binding preference (native or JS-only)
3. Refactor ConnectionCollection to be more testable
    1. Inject Pool?
    2. Inject Client?
4. Integration test that hits dbs

## License

Copyright (c) 2013 IFTTT

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
