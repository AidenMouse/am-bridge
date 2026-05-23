local Adapter = {
    name = 'qb',
    label = 'qb-inventory'
}

local QBCore = nil

local function getCore()
    if QBCore then
        return QBCore
    end

    if GetResourceState('qb-core') ~= 'started' then
        return nil
    end

    local ok, core = pcall(function()
        return exports['qb-core']:GetCoreObject()
    end)

    if ok and core then
        QBCore = core
    end

    return QBCore
end

local function getPlayer(source)
    local core = getCore()
    if not core or not core.Functions then
        return nil
    end

    return core.Functions.GetPlayer(source)
end

function Adapter.IsActive(isResourceStarted)
    return isResourceStarted('qb-inventory') or isResourceStarted('qb-core')
end

function Adapter.HasItem(source, item, amount)
    if not item then
        return false
    end

    local player = getPlayer(source)
    if not player or not player.Functions then
        return false
    end

    local itemData = player.Functions.GetItemByName(item)
    return itemData and (itemData.amount or 0) >= (amount or 1)
end

function Adapter.AddItem(source, item, amount, metadata)
    if not item then
        return false
    end

    local player = getPlayer(source)
    if not player or not player.Functions then
        return false
    end

    return player.Functions.AddItem(item, amount or 1, false, metadata) == true
end

function Adapter.RemoveItem(source, item, amount)
    if not item then
        return false
    end

    local player = getPlayer(source)
    if not player or not player.Functions then
        return false
    end

    return player.Functions.RemoveItem(item, amount or 1) == true
end

AMBridge.RegisterInventory('qb', Adapter)
