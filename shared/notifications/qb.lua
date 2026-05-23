local Adapter = {
    name = 'qb',
    label = 'QBCore Notify'
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

function Adapter.IsActive(isResourceStarted)
    return isResourceStarted('qb-core')
end

function Adapter.Notify(source, message, notifyType, duration)
    if not message then
        return false
    end

    if IsDuplicityVersion() then
        TriggerClientEvent('QBCore:Notify', source, message, notifyType or 'primary', duration or 5000)
    else
        local core = getCore()
        if core and core.Functions then
            core.Functions.Notify(message, notifyType or 'primary', duration or 5000)
        else
            TriggerEvent('chat:addMessage', {
                args = { 'AM-Bridge', message }
            })
        end
    end

    return true
end

AMBridge.RegisterNotification('qb', Adapter)
