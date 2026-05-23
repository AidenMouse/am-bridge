local function ensureAdapters()
    if not AMBridge.Framework or not AMBridge.Inventory or not AMBridge.Notification then
        AMBridge.RefreshAdapters()
    end
end

local function getServerId()
    return GetPlayerServerId(PlayerId())
end

function GetFramework()
    ensureAdapters()
    return AMBridge.GetFramework()
end

function GetPlayer()
    return PlayerPedId()
end

function GetIdentifier()
    print('[AM-Bridge] GetIdentifier is server-side. Use TriggerCallback or a server export for identifiers.')
    return nil
end

function GetName()
    return GetPlayerName(PlayerId()) or 'Unknown'
end

function GetJob()
    print('[AM-Bridge] GetJob is server-side for reliable framework data.')
    return nil
end

function GetMoney(account)
    print('[AM-Bridge] GetMoney is server-side for reliable framework data.')
    return 0
end

function AddMoney(account, amount)
    print('[AM-Bridge] AddMoney is server-side only.')
    return false
end

function RemoveMoney(account, amount)
    print('[AM-Bridge] RemoveMoney is server-side only.')
    return false
end

function HasItem(item, amount, cb)
    if type(cb) ~= 'function' then
        print('[AM-Bridge] HasItem on client requires a callback function.')
        return false
    end

    TriggerCallback('am-bridge:hasItem', cb, item, amount)
    return true
end

function AddItem(item, amount, metadata)
    print('[AM-Bridge] AddItem is server-side only.')
    return false
end

function RemoveItem(item, amount)
    print('[AM-Bridge] RemoveItem is server-side only.')
    return false
end

function Notify(source, message, notifyType, duration)
    ensureAdapters()

    if type(source) == 'string' then
        duration = notifyType
        notifyType = message
        message = source
    end

    return AMBridge.Notify(getServerId(), message, notifyType, duration)
end

function RegisterCallback(name, cb)
    if type(name) ~= 'string' or type(cb) ~= 'function' then
        print('[AM-Bridge] RegisterCallback failed: expected name and function.')
        return false
    end

    AMBridge.ClientCallbacks[name] = cb
    return true
end

function TriggerCallback(name, cb, ...)
    if type(name) ~= 'string' or type(cb) ~= 'function' then
        print('[AM-Bridge] TriggerCallback failed: expected name and function.')
        return false
    end

    AMBridge.CallbackRequestId = AMBridge.CallbackRequestId + 1
    local requestId = AMBridge.CallbackRequestId

    AMBridge.PendingCallbacks[requestId] = cb
    TriggerServerEvent('am-bridge:server:triggerCallback', name, requestId, ...)
    return true
end

RegisterNetEvent('am-bridge:client:triggerCallback', function(name, requestId, ...)
    local callback = AMBridge.ClientCallbacks[name]

    if not callback then
        TriggerServerEvent('am-bridge:server:callbackResponse', requestId, nil)
        return
    end

    callback(function(...)
        TriggerServerEvent('am-bridge:server:callbackResponse', requestId, ...)
    end, ...)
end)

RegisterNetEvent('am-bridge:client:callbackResponse', function(requestId, ...)
    local callback = AMBridge.PendingCallbacks[requestId]
    if not callback then
        return
    end

    AMBridge.PendingCallbacks[requestId] = nil
    callback(...)
end)

RegisterCommand('ambridge', function()
    local info = AMBridge.GetDebugInfo()

    TriggerEvent('chat:addMessage', {
        args = { 'AM-Bridge', ('Framework: %s'):format(info.framework) }
    })

    TriggerEvent('chat:addMessage', {
        args = { 'AM-Bridge', ('Inventory: %s'):format(info.inventory) }
    })

    TriggerEvent('chat:addMessage', {
        args = { 'AM-Bridge', ('Notification: %s'):format(info.notification) }
    })
end, false)

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
