local Adapter = {
    name = 'qbox',
    label = 'Qbox'
}

local function hasQbox()
    return GetResourceState('qbx_core') == 'started'
end

function Adapter.IsActive(isResourceStarted)
    return isResourceStarted('qbx_core')
end

function Adapter.GetPlayer(source)
    if not hasQbox() then
        return nil
    end

    local ok, player = pcall(function()
        return exports['qbx_core']:GetPlayer(source)
    end)

    return ok and player or nil
end

function Adapter.GetIdentifier(source)
    local player = Adapter.GetPlayer(source)
    if player and player.PlayerData then
        return player.PlayerData.citizenid or player.PlayerData.license
    end

    local ok, citizenId = pcall(function()
        local player = exports['qbx_core']:GetPlayer(source)
        return player and player.PlayerData and player.PlayerData.citizenid or nil
    end)

    return ok and citizenId or nil
end

function Adapter.GetName(source)
    local player = Adapter.GetPlayer(source)
    local data = player and player.PlayerData or {}
    local charinfo = data.charinfo or {}
    local firstName = charinfo.firstname or ''
    local lastName = charinfo.lastname or ''
    local fullName = (firstName .. ' ' .. lastName):gsub('^%s*(.-)%s*$', '%1')

    return fullName ~= '' and fullName or GetPlayerName(source) or 'Unknown'
end

function Adapter.GetJob(source)
    local player = Adapter.GetPlayer(source)
    local job = player and player.PlayerData and player.PlayerData.job or {}
    local grade = job.grade or {}

    return {
        name = job.name or 'unemployed',
        label = job.label or job.name or 'Unemployed',
        grade = grade.level or grade.grade or 0,
        gradeLabel = grade.name or 'None',
        onDuty = job.onduty or false
    }
end

function Adapter.GetMoney(source, account)
    local player = Adapter.GetPlayer(source)
    if player and player.Functions and player.Functions.GetMoney then
        return player.Functions.GetMoney(account) or 0
    end

    local ok, money = pcall(function()
        return exports['qbx_core']:GetMoney(source, account)
    end)

    return ok and money or 0
end

function Adapter.AddMoney(source, account, amount)
    local player = Adapter.GetPlayer(source)
    if player and player.Functions and player.Functions.AddMoney then
        player.Functions.AddMoney(account, amount, 'am-bridge')
        return true
    end

    local ok, result = pcall(function()
        return exports['qbx_core']:AddMoney(source, account, amount, 'am-bridge')
    end)

    return ok and result ~= false
end

function Adapter.RemoveMoney(source, account, amount)
    local player = Adapter.GetPlayer(source)
    if player and player.Functions and player.Functions.RemoveMoney then
        return player.Functions.RemoveMoney(account, amount, 'am-bridge') == true
    end

    local ok, result = pcall(function()
        return exports['qbx_core']:RemoveMoney(source, account, amount, 'am-bridge')
    end)

    return ok and result ~= false
end

AMBridge.RegisterFramework('qbox', Adapter)
