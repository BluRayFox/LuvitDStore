local router = {}
local routes = require('./routes')

local function p(message)
    print(('[%s]: %s'):format(os.time(), message))
end

function router.handler(req, res)
    
    p(('%s -> %s'):format(req.method, req.url))

    for k, route in pairs(routes) do
        if route.path == req.url and route.method == req.method then
            route.handler(req, res)
        end
    end

end

return router