local function ensureAdapters()
    if not AMBridge.Framework or not AMBridge.Inventory or not AMBridge.Notification then
        AMBridge.RefreshAdapters()
    end
end

local function printDebug(source)
    ensureAdapters()

    local info = AMBridge.GetDebugInfo()
    local lines = {
        ('Framework: %s'):format(info.framework),
        ('Inventory: %s'):format(info.inventory),
        ('Notification: %s'):format(info.notification)
    }

    if source and source > 0 then
        for index = 1, #lines do
            TriggerClientEvent('chat:addMessage', source, {
                args = { 'AM-Bridge', lines[index] }
            })
        end
    else
        for index = 1, #lines do
            print(('[AM-Bridge] %s'):format(lines[index]))
        end
    end
end

RegisterCommand('ambridge', function(source)
    printDebug(source)
end, false)

function GetFramework()
    ensureAdapters()
    return AMBridge.GetFramework()
end

function GetPlayer(source)
    ensureAdapters()
    return AMBridge.GetPlayer(source)
end

function GetIdentifier(source)
    ensureAdapters()
    return AMBridge.GetIdentifier(source)
end

function GetName(source)
    ensureAdapters()
    return AMBridge.GetName(source)
end

function GetJob(source)
    ensureAdapters()
    return AMBridge.GetJob(source)
end

function GetMoney(source, account)
    ensureAdapters()
    return AMBridge.GetMoney(source, account)
end

function AddMoney(source, account, amount)
    ensureAdapters()
    return AMBridge.AddMoney(source, account, amount)
end

function RemoveMoney(source, account, amount)
    ensureAdapters()
    return AMBridge.RemoveMoney(source, account, amount)
end

function HasItem(source, item, amount)
    ensureAdapters()
    return AMBridge.HasItem(source, item, amount)
end

function AddItem(source, item, amount, metadata)
    ensureAdapters()
    return AMBridge.AddItem(source, item, amount, metadata)
end

function RemoveItem(source, item, amount)
    ensureAdapters()
    return AMBridge.RemoveItem(source, item, amount)
end

function Notify(source, message, notifyType, duration)
    ensureAdapters()
    return AMBridge.Notify(source, message, notifyType, duration)
end

function RegisterCallback(name, cb)
    if type(name) ~= 'string' or type(cb) ~= 'function' then
        print('[AM-Bridge] RegisterCallback failed: expected name and function.')
        return false
    end

    AMBridge.ServerCallbacks[name] = cb
    return true
end

RegisterCallback('am-bridge:hasItem', function(source, cb, item, amount)
    cb(HasItem(source, item, amount))
end)

function TriggerCallback(source, name, cb, ...)
    if type(source) ~= 'number' or type(name) ~= 'string' or type(cb) ~= 'function' then
        print('[AM-Bridge] TriggerCallback failed: expected source, name, and function.')
        return false
    end

    AMBridge.CallbackRequestId = AMBridge.CallbackRequestId + 1
    local requestId = AMBridge.CallbackRequestId

    AMBridge.PendingCallbacks[requestId] = cb
    TriggerClientEvent('am-bridge:client:triggerCallback', source, name, requestId, ...)
    return true
end

RegisterNetEvent('am-bridge:server:triggerCallback', function(name, requestId, ...)
    local source = source
    local callback = AMBridge.ServerCallbacks[name]

    if not callback then
        TriggerClientEvent('am-bridge:client:callbackResponse', source, requestId, nil)
        return
    end

    callback(source, function(...)
        TriggerClientEvent('am-bridge:client:callbackResponse', source, requestId, ...)
    end, ...)
end)

RegisterNetEvent('am-bridge:server:callbackResponse', function(requestId, ...)
    local callback = AMBridge.PendingCallbacks[requestId]
    if not callback then
        return
    end

    AMBridge.PendingCallbacks[requestId] = nil
    callback(...)
end)

exports('GetFramework', GetFramework)
exports('GetPlayer', GetPlayer)
exports('GetIdentifier', GetIdentifier)
exports('GetName', GetName)
exports('GetJob', GetJob)
exports('GetMoney', GetMoney)
exports('AddMoney', AddMoney)
exports('RemoveMoney', RemoveMoney)
exports('HasItem', HasItem)
exports('AddItem', AddItem)
exports('RemoveItem', RemoveItem)
exports('Notify', Notify)
exports('RegisterCallback', RegisterCallback)
exports('TriggerCallback', TriggerCallback)
