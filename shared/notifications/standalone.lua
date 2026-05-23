local Adapter = {
    name = 'standalone',
    label = 'Standalone Chat'
}

function Adapter.IsActive()
    return true
end

function Adapter.Notify(source, message)
    if not message then
        return false
    end

    if IsDuplicityVersion() then
        TriggerClientEvent('chat:addMessage', source, {
            args = { 'AM-Bridge', message }
        })
    else
        TriggerEvent('chat:addMessage', {
            args = { 'AM-Bridge', message }
        })
    end

    return true
end

AMBridge.RegisterNotification('standalone', Adapter)
