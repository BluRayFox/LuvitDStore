-- Datastore Handler

local datastore = {}
local utils = require('./utils')
local json = require('json')
local fs = require('fs')

local data = {}
local tokens = {}

local function tokenCheck(token, uni)
    if type(token) ~= 'string' then
        error('Invalid token provided.', 3)
    elseif type(uni) ~= 'number' then
        error('Invalid universe provided.', 3)
    end

    if not tokens[token] then
        error('Such token does not exist.')
    elseif not tokens[token].uIDs then
        error('Invalid token format.')
    end

    for i, id in ipairs(tokens[token].uIDs) do
        if id == uni then
            return true
        end
    end

    return false
end

function datastore:load()
    utils.ensureDir('./data/')
    utils.ensureDir('./data/universes/')

    local tokensData = fs.readFileSync('./data/tokens.json')
    local tokensDecoded = (tokensData and json.decode(tokensData)) or {}

    tokens = tokensDecoded
    datastore.tokens = tokens

    print('Datastore Loaded.')
end

function datastore:save()
    local tokensEncoded = json.encode(tokens)
    fs.writeFileSync('./data/tokens.json', tokensEncoded)
end

function datastore:get(token, uni, key)
    local pass = tokenCheck(token, uni)
    if not pass then return end

    local path = ('./data/universes/%s/'):format(uni)
    utils.ensureDir(path)

    local data = fs.readFileSync(path .. 'data.json') or '{}'
    local decoded = json.decode(data)

    return decoded and decoded[key]
end

function datastore:set(token, uni, key, val)
    local pass = tokenCheck(token, uni)
    if not pass then return end

    local path = ('./data/universes/%s/'):format(uni)
    utils.ensureDir(path)

    if type(val) == "table" then val = json.encode(val) end

    local data = fs.readFileSync(path .. 'data.json')
    local decoded = data and json.decode(data) or {}; data = nil

    decoded[key] = val

    local encoded = json.encode(decoded); decoded = nil
    fs.writeFileSync(path .. 'data.json', encoded)
end

function datastore:newToken(lenght)
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local t = ''
    for i=1, lenght or 32 do
        local rand = math.random(1, #charset)
        t = t .. charset:sub(rand, rand)
    end

    tokens[t] = {uIDs = {}}
    datastore:save()

    return t
end

return datastore