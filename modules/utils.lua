local utils = {}
local fs = require('fs')

utils.ensureDir = function(path)
    if not fs.existsSync(path) then
        fs.mkdirSync(path)
    end
end

return utils