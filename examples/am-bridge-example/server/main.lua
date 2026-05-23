local function runBridgeTest(source)
    local identifier = exports['am-bridge']:GetIdentifier(source)
    local name = exports['am-bridge']:GetName(source)
    local job = exports['am-bridge']:GetJob(source)

    if not identifier then
        exports['am-bridge']:Notify(source, 'Could not find your player identifier.', 'error', 5000)
        return
    end

    if not exports['am-bridge']:HasItem(source, Config.RequiredItem, Config.RequiredAmount) then
        exports['am-bridge']:Notify(source, ('You need %sx %s.'):format(Config.RequiredAmount, Config.RequiredItem), 'error', 5000)
        return
    end

    local removed = exports['am-bridge']:RemoveItem(source, Config.RequiredItem, Config.RequiredAmount)
    if not removed then
        exports['am-bridge']:Notify(source, 'Could not remove the required item.', 'error', 5000)
        return
    end

    exports['am-bridge']:AddMoney(source, Config.RewardAccount, Config.RewardAmount)
    exports['am-bridge']:Notify(source, ('Bridge test passed. Paid $%s.'):format(Config.RewardAmount), 'success', 5000)

    print(('[am-bridge-example] %s (%s) used the bridge. Job: %s'):format(name, identifier, job.name))
end

RegisterNetEvent('am-bridge-example:server:useBridge', function()
    runBridgeTest(source)
end)

RegisterCommand('ambridge_server_test', function(source)
    if source <= 0 then
        print('[am-bridge-example] This command must be used in-game.')
        return
    end

    runBridgeTest(source)
end, false)
