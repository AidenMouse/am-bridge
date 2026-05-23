local Adapter = {
    name = 'unc',
    label = 'unc_core Inventory'
}

local UNC = nil

local function getCore()
    if UNC then
        return UNC
    end

    if GetResourceState('unc_core') ~= 'started' then
        return nil
    end

    local ok, core = pcall(function()
        return exports['unc_core']:GetCoreObject()
    end)

    if ok and core then
        UNC = core
    end

    return UNC
end

local function getPlayer(source)
    local core = getCore()
    if not core or not core.Functions or not core.Functions.GetPlayer then
        return nil
    end

    return core.Functions.GetPlayer(source)
end

local function getInventory(source)
    local player = getPlayer(source)
    if not player or not player.PlayerData then
        return nil, nil
    end

    player.PlayerData.inventory = player.PlayerData.inventory or {}
    return player.PlayerData.inventory, player
end

local function getItemAmount(itemData)
    if type(itemData) == 'number' then
        return itemData
    end

    if type(itemData) == 'table' then
        return tonumber(itemData.amount or itemData.count or itemData.quantity) or 0
    end

    return 0
end

local function setItemAmount(inventory, key, item, amount, metadata)
    if amount <= 0 then
        inventory[key] = nil
        return
    end

    local existing = inventory[key]
    if type(existing) == 'table' then
        existing.amount = amount
        existing.count = nil
        existing.quantity = nil
        existing.info = metadata or existing.info
        existing.metadata = metadata or existing.metadata
        inventory[key] = existing
        return
    end

    inventory[key] = {
        name = item,
        amount = amount,
        info = metadata or {},
        metadata = metadata or {}
    }
end

local function findItem(inventory, item)
    if inventory[item] ~= nil then
        return item, inventory[item]
    end

    for key, value in pairs(inventory) do
        if type(value) == 'table' and value.name == item then
            return key, value
        end
    end

    return nil, nil
end

local function savePlayer(player)
    if player and player.Functions and player.Functions.Save then
        player.Functions.Save()
    end
end

function Adapter.IsActive(isResourceStarted)
    return isResourceStarted('unc_core')
end

function Adapter.HasItem(source, item, amount)
    if not item then
        return false
    end

    local inventory = getInventory(source)
    if not inventory then
        return false
    end

    local _, itemData = findItem(inventory, item)
    return getItemAmount(itemData) >= (amount or 1)
end

function Adapter.AddItem(source, item, amount, metadata)
    if not item then
        return false
    end

    local inventory, player = getInventory(source)
    if not inventory then
        return false
    end

    amount = tonumber(amount) or 1
    local key, itemData = findItem(inventory, item)

    if not key then
        key = item
    end

    setItemAmount(inventory, key, item, getItemAmount(itemData) + amount, metadata)
    savePlayer(player)
    return true
end

function Adapter.RemoveItem(source, item, amount)
    if not item then
        return false
    end

    local inventory, player = getInventory(source)
    if not inventory then
        return false
    end

    amount = tonumber(amount) or 1
    local key, itemData = findItem(inventory, item)
    local currentAmount = getItemAmount(itemData)

    if not key or currentAmount < amount then
        return false
    end

    setItemAmount(inventory, key, item, currentAmount - amount)
    savePlayer(player)
    return true
end

AMBridge.RegisterInventory('unc', Adapter)
