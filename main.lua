local http = require('http')
local router = require('./modules/router')

http.createServer(function(req, res)
    router.handler(req, res)
end):listen(8080)

print('Self-Hosted Datastore is Running on: http://localhost:8080')