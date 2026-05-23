RegisterCommand('ambridge_client_test', function()
    local framework = exports['am-bridge']:GetFramework()

    exports['am-bridge']:Notify(('AM-Bridge detected: %s'):format(framework), 'inform', 5000)
    TriggerServerEvent('am-bridge-example:server:useBridge')
end, false)
