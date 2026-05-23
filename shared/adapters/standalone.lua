local Adapter = {
    name = 'standalone',
    label = 'Standalone'
}

function Adapter.IsActive()
    return true
end

function Adapter.GetPlayer(source)
    return {
        source = source,
        identifier = Adapter.GetIdentifier(source),
        name = Adapter.GetName(source)
    }
end

function Adapter.GetIdentifier(source)
    local identifiers = GetPlayerIdentifiers(source)
    return identifiers and identifiers[1] or nil
end

function Adapter.GetName(source)
    return GetPlayerName(source) or 'Unknown'
end

function Adapter.GetJob()
    return {
        name = 'unemployed',
        label = 'Unemployed',
        grade = 0,
        gradeLabel = 'None',
        onDuty = false
    }
end

function Adapter.GetMoney()
    return 0
end

function Adapter.AddMoney()
    return false
end

function Adapter.RemoveMoney()
    return false
end

AMBridge.RegisterFramework('standalone', Adapter)
