local utils = require('./utils')
local fs = require('fs')
local json = require('json')
local DSManager = {}

utils.ensureDirSync('./data/datastore/userdata')    -- userdata
utils.ensureDirSync('./data/etc/')                  -- configs

function DSManager.getV1(token, gameid, datastoreName, key, req)
    if not token or not gameid or not datastoreName or not key then
        return false, -1
    end
    
    local path = './data/datastore/userdata/%s/%s/%s'
    path = path:format(token, gameid, datastoreName)
    utils.ensureDirSync(path)

    local success, data = pcall(fs.readFileSync, path .. '/'..key..'.json')
    local ok, decodedData = pcall(json.decode, data)
    decodedData = ok and decodedData or {}

    local dataType = decodedData['lua-type'] or nil
    local dataValue = decodedData['data'] or nil
    local dataVersion = decodedData['version']

    if not dataVersion then
        return false, -4 -- malformed data
    end

    if dataVersion ~= 1 then
        return false, -2 -- version mismatch
    end

    return true, {['lua-type'] = dataType, data = dataValue}
end

function DSManager.setV1(token, gameid, datastoreName, key, decodedBody, req)
    if not token or not gameid or not datastoreName or not key or not decodedBody then
        return false, -1
    end
    
    local value = decodedBody and decodedBody['data']

    local path = './data/datastore/userdata/%s/%s/%s'
    path = path:format(token, gameid, datastoreName)
    utils.ensureDirSync(path)

    local data = {}
    data.ip = req and req.socket and req.socket:getsockname().ip or "unknown"
    data.timestamp = os.time()
    data['lua-type'] = type(value)
    data.data = value
    data.version = 1

    local encoded = json.encode(data)
    local success, err = pcall(fs.writeFileSync, path .. '/'..key..'.json', encoded)

    return success, err
end

return DSManager