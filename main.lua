local router = require('./modules/router')
local http = require('http')
local utils = require('./modules/utils')
local datastore = require('./modules/datastore')    -- Datastore Handler


datastore:load()
datastore:set(nil, 1, 'test', 'hi')


http.createServer(function(req, res)
    router.handler(req, res)
end):listen(8080)

print('Running on http://localhost:8080')