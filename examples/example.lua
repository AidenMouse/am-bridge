if not Config.EnableExampleUsagePrint then
    return
end

CreateThread(function()
    Wait(1000)

    print('[AM-Bridge Example] Server export examples:')
    print("[AM-Bridge Example] local framework = exports['am-bridge']:GetFramework()")
    print("[AM-Bridge Example] local identifier = exports['am-bridge']:GetIdentifier(source)")
    print("[AM-Bridge Example] exports['am-bridge']:Notify(source, 'Hello from AM-Bridge', 'success', 5000)")
end)
