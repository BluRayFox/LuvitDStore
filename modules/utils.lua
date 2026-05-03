local fs = require('fs')
local path = require('path')
local json = require('json')

local utils = {}


function utils.ensureDirSync(dir)
    if fs.existsSync(dir) then
        return true
    end

    local parent = path.dirname(dir)

    if parent ~= dir then
        utils.ensureDirSync(parent)
    end

    local ok, err = pcall(fs.mkdirSync, dir)
    if not ok then
        if not fs.existsSync(dir) then
        error(err)
        end
    end

    return true
end

return utils