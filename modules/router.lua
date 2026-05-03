local router = {}
local url = require('url')
local json = require('json')
local DSManager = require('./DSManager')
local routes = {}

local function addRoute(path, handler)
    routes[path] = handler
end

local function removeRoute(path)
    routes[path] = nil
end

function router.handler(req, res)
    local parsedUrl = url.parse(req.url)
    local pathname = parsedUrl.pathname

    for path, handler in pairs(routes) do
        if path == pathname and handler then
            handler(req, res)
            return
        end
    end

    res.statusCode = 404
    res:finish('Not Found')
    return
end

addRoute('/', function(req, res)
    res:finish('Hi! <3')
end)

addRoute('/datastore/v1/get', function(req, res)
    local token, gameid, datastoreName, key = req.headers['auth'], req.headers['id'], req.headers['datastorename'], req.headers['key']

    if not token or not gameid or not datastoreName or not key then
        res.statusCode = 400
        res:finish('Bad Request')
        return
    end

    if req.method ~= 'GET' then
        res.statusCode = 405
        res:setHeader('Allow', 'GET')
        res:finish('Method Not Allowed')
        return
    end

    local success, data = DSManager.getV1(token, gameid, datastoreName, key, req)

    if success and data then
        res:finish(json.encode(data))
    else
        res.statusCode = 404
        res:finish('Not Found')
    end
end)

addRoute('/datastore/v1/set', function(req, res)
    local token, gameid, datastoreName, key = req.headers['auth'], req.headers['id'], req.headers['datastorename'], req.headers['key']
    local chunks, body = {}, ''

    if not token or not gameid or not datastoreName or not key then
        res.statusCode = 400
        res:finish('Bad Request')
        return
    end

    if req.method ~= 'POST' and req.method ~= 'PATCH' then
        res.statusCode = 405
        res:setHeader('Allow', 'POST, PATCH')
        res:finish('Method Not Allowed')
        return
    end

    req:on('data', function(chunk)
        table.insert(chunks, chunk)
    end)

    req:on('end', function(chunk)
        if chunk then table.insert(chunks, chunk) end
        body = table.concat(chunks)

        if not body or body == '' then
            res.statusCode = 400
            res:finish('Bad Request')
            return
        end

        local ok, decoded = pcall(json.decode, body)
        if not decoded or not decoded['lua-type'] then
            res.statusCode = 400
            res:finish('Bad Request')
            return
        end


        local success, err = DSManager.setV1(token, gameid, datastoreName, key, decoded, req)

        res:finish('OK!')

    end)
end)


return router