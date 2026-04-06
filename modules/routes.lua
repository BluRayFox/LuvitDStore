local routes = {}
local fs = require('fs')
local utils = require('./utils')

local function addRoute(path, method, handler)
    local route = {}
    route.path = path
    route.method = method
    route.handler = handler

    table.insert(routes, route)
end

addRoute('/', 'GET', function(req, res)
    res:finish('Hi! <3')
end)

return routes