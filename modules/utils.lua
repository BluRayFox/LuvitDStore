local utils = {}
local fs = require('fs')

utils.ensureDir = function(path)
    local exist = fs.statSync(path)
    if exist then return true end

    fs.mkdir(path)
end

return utils