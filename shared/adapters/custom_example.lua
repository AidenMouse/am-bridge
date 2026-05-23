--[[
    AM-Bridge custom framework example

    To add your own framework:
    1. Copy this file and rename it, for example shared/adapters/myframework.lua.
    2. Add the new file to fxmanifest.lua under shared_scripts.
    3. Change Adapter.name and Adapter.label.
    4. Update IsActive() so it returns true when your framework is running.
    5. Fill in the functions below using your framework's API.
    6. Add your adapter name to Config.FrameworkPriority in config.lua.

    Your other scripts should keep using AM-Bridge exports. They do not need to
    know which framework is active.
]]

local Adapter = {
    name = 'custom_example',
    label = 'Custom Framework Example'
}

function Adapter.IsActive(isResourceStarted)
    -- Return true when your framework resource is started.
    -- Example: return isResourceStarted('my_framework')
    return false
end

function Adapter.GetPlayer(source)
    return nil
end

function Adapter.GetIdentifier(source)
    return nil
end

function Adapter.GetName(source)
    return GetPlayerName(source) or 'Unknown'
end

function Adapter.GetJob(source)
    return {
        name = 'unemployed',
        label = 'Unemployed',
        grade = 0,
        gradeLabel = 'None',
        onDuty = false
    }
end

function Adapter.GetMoney(source, account)
    return 0
end

function Adapter.AddMoney(source, account, amount)
    return false
end

function Adapter.RemoveMoney(source, account, amount)
    return false
end

AMBridge.RegisterFramework('custom_example', Adapter)
