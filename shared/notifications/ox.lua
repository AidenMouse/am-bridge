local Adapter = {
    name = 'ox',
    label = 'ox_lib'
}

function Adapter.IsActive(isResourceStarted)
    return isResourceStarted('ox_lib')
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
        local notifyData = {
            title = 'AM-Bridge',
            description = message,
            type = notifyType or 'inform',
            duration = duration or 5000
        }

        if lib and lib.notify then
            lib.notify(notifyData)
        else
            TriggerEvent('ox_lib:notify', notifyData)
        end
    end

    return true
end

AMBridge.RegisterNotification('ox', Adapter)
