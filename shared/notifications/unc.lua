local Adapter = {
    name = 'unc',
    label = 'unc_core Notify'
}

function Adapter.IsActive(isResourceStarted)
    return isResourceStarted('unc_core')
end

function Adapter.Notify(source, message, notifyType, duration)
    if not message then
        return false
    end

    if IsDuplicityVersion() then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'AM-Bridge',
            description = message,
            type = notifyType or 'inform',
            duration = duration or 5000
        })
    else
        local ok = pcall(function()
            exports['unc_core']:Notify(message, notifyType or 'inform', duration or 5000)
        end)

        if not ok then
            TriggerEvent('ox_lib:notify', {
                title = 'AM-Bridge',
                description = message,
                type = notifyType or 'inform',
                duration = duration or 5000
            })
        end
    end

    return true
end

AMBridge.RegisterNotification('unc', Adapter)
