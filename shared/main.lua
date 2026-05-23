AMBridge = AMBridge or {}

AMBridge.FrameworkAdapters = AMBridge.FrameworkAdapters or {}
AMBridge.InventoryAdapters = AMBridge.InventoryAdapters or {}
AMBridge.NotificationAdapters = AMBridge.NotificationAdapters or {}

AMBridge.Framework = AMBridge.Framework or nil
AMBridge.Inventory = AMBridge.Inventory or nil
AMBridge.Notification = AMBridge.Notification or nil

AMBridge.ServerCallbacks = AMBridge.ServerCallbacks or {}
AMBridge.ClientCallbacks = AMBridge.ClientCallbacks or {}
AMBridge.PendingCallbacks = AMBridge.PendingCallbacks or {}
AMBridge.CallbackRequestId = AMBridge.CallbackRequestId or 0

local function bridgePrint(message)
    print(('[AM-Bridge] %s'):format(message))
end

local function isResourceStarted(resourceName)
    return GetResourceState(resourceName) == 'started'
end

local function getContext()
    return IsDuplicityVersion() and 'server' or 'client'
end

local function getPriority(configKey, fallback)
    if Config and Config[configKey] then
        return Config[configKey]
    end

    return fallback
end

function AMBridge.RegisterFramework(name, adapter)
    if type(name) ~= 'string' or type(adapter) ~= 'table' then
        bridgePrint('Failed to register framework adapter: invalid name or adapter.')
        return false
    end

    AMBridge.FrameworkAdapters[name] = adapter
    return true
end

function AMBridge.RegisterInventory(name, adapter)
    if type(name) ~= 'string' or type(adapter) ~= 'table' then
        bridgePrint('Failed to register inventory adapter: invalid name or adapter.')
        return false
    end

    AMBridge.InventoryAdapters[name] = adapter
    return true
end

function AMBridge.RegisterNotification(name, adapter)
    if type(name) ~= 'string' or type(adapter) ~= 'table' then
        bridgePrint('Failed to register notification adapter: invalid name or adapter.')
        return false
    end

    AMBridge.NotificationAdapters[name] = adapter
    return true
end

local function selectAdapter(adapterType, adapters, priority)
    for index = 1, #priority do
        local name = priority[index]
        local adapter = adapters[name]

        if adapter and type(adapter.IsActive) == 'function' and adapter.IsActive(isResourceStarted, getContext()) then
            bridgePrint(('Detected %s: %s'):format(adapterType, adapter.label or name))
            return adapter
        end
    end

    local standalone = adapters.standalone
    if standalone then
        bridgePrint(('Using standalone %s fallback.'):format(adapterType))
        return standalone
    end

    bridgePrint(('No %s adapter could be selected.'):format(adapterType))
    return nil
end

function AMBridge.RefreshAdapters()
    AMBridge.Framework = selectAdapter('framework', AMBridge.FrameworkAdapters, getPriority('FrameworkPriority', {
        'qbox',
        'qb',
        'standalone'
    }))

    AMBridge.Inventory = selectAdapter('inventory', AMBridge.InventoryAdapters, getPriority('InventoryPriority', {
        'ox',
        'qb',
        'standalone'
    }))

    AMBridge.Notification = selectAdapter('notification', AMBridge.NotificationAdapters, getPriority('NotificationPriority', {
        'ox',
        'qb',
        'standalone'
    }))
end

function AMBridge.GetFramework()
    if not AMBridge.Framework then
        AMBridge.RefreshAdapters()
    end

    return AMBridge.Framework and AMBridge.Framework.name or 'standalone'
end

function AMBridge.GetInventory()
    if not AMBridge.Inventory then
        AMBridge.RefreshAdapters()
    end

    return AMBridge.Inventory and AMBridge.Inventory.name or 'standalone'
end

function AMBridge.GetNotification()
    if not AMBridge.Notification then
        AMBridge.RefreshAdapters()
    end

    return AMBridge.Notification and AMBridge.Notification.name or 'standalone'
end

local function callAdapter(adapter, functionName, fallback, ...)
    if adapter and type(adapter[functionName]) == 'function' then
        local ok, result = pcall(adapter[functionName], ...)

        if ok then
            return result
        end

        bridgePrint(('%s failed: %s'):format(functionName, result))
    end

    if fallback ~= nil then
        return fallback
    end

    return nil
end

function AMBridge.GetPlayer(source)
    return callAdapter(AMBridge.Framework, 'GetPlayer', nil, source)
end

function AMBridge.GetIdentifier(source)
    return callAdapter(AMBridge.Framework, 'GetIdentifier', nil, source)
end

function AMBridge.GetName(source)
    return callAdapter(AMBridge.Framework, 'GetName', GetPlayerName(source) or 'Unknown', source)
end

function AMBridge.GetJob(source)
    return callAdapter(AMBridge.Framework, 'GetJob', {
        name = 'unemployed',
        label = 'Unemployed',
        grade = 0,
        gradeLabel = 'None',
        onDuty = false
    }, source)
end

function AMBridge.GetMoney(source, account)
    account = account or Config.DefaultMoneyAccount
    return callAdapter(AMBridge.Framework, 'GetMoney', 0, source, account)
end

function AMBridge.AddMoney(source, account, amount)
    account = account or Config.DefaultMoneyAccount
    amount = tonumber(amount) or 0

    if amount <= 0 then
        return false
    end

    return callAdapter(AMBridge.Framework, 'AddMoney', false, source, account, amount)
end

function AMBridge.RemoveMoney(source, account, amount)
    account = account or Config.DefaultMoneyAccount
    amount = tonumber(amount) or 0

    if amount <= 0 then
        return false
    end

    return callAdapter(AMBridge.Framework, 'RemoveMoney', false, source, account, amount)
end

function AMBridge.HasItem(source, item, amount)
    amount = tonumber(amount) or 1
    return callAdapter(AMBridge.Inventory, 'HasItem', false, source, item, amount)
end

function AMBridge.AddItem(source, item, amount, metadata)
    amount = tonumber(amount) or 1
    return callAdapter(AMBridge.Inventory, 'AddItem', false, source, item, amount, metadata)
end

function AMBridge.RemoveItem(source, item, amount)
    amount = tonumber(amount) or 1
    return callAdapter(AMBridge.Inventory, 'RemoveItem', false, source, item, amount)
end

function AMBridge.Notify(source, message, notifyType, duration)
    notifyType = notifyType or Config.DefaultNotifyType
    duration = tonumber(duration) or Config.DefaultNotifyDuration
    return callAdapter(AMBridge.Notification, 'Notify', false, source, message, notifyType, duration)
end

function AMBridge.GetDebugInfo()
    return {
        framework = AMBridge.GetFramework(),
        inventory = AMBridge.GetInventory(),
        notification = AMBridge.GetNotification()
    }
end

CreateThread(function()
    Wait(250)
    AMBridge.RefreshAdapters()
end)
