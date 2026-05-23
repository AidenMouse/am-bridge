local Adapter = {
    name = 'qb',
    label = 'QBCore'
}

local QBCore = nil

local function getCore()
    if QBCore then
        return QBCore
    end

    if GetResourceState('qb-core') ~= 'started' then
        return nil
    end

    local ok, core = pcall(function()
        return exports['qb-core']:GetCoreObject()
    end)

    if ok and core then
        QBCore = core
    end

    return QBCore
end

function Adapter.IsActive(isResourceStarted)
    return isResourceStarted('qb-core')
end

function Adapter.GetPlayer(source)
    local core = getCore()
    if not core or not core.Functions then
        return nil
    end

    return core.Functions.GetPlayer(source)
end

function Adapter.GetIdentifier(source)
    local player = Adapter.GetPlayer(source)
    return player and player.PlayerData and player.PlayerData.citizenid or nil
end

function Adapter.GetName(source)
    local player = Adapter.GetPlayer(source)
    if not player or not player.PlayerData then
        return GetPlayerName(source) or 'Unknown'
    end

    local charinfo = player.PlayerData.charinfo or {}
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
    if not player or not player.Functions then
        return 0
    end

    return player.Functions.GetMoney(account) or 0
end

function Adapter.AddMoney(source, account, amount)
    local player = Adapter.GetPlayer(source)
    if not player or not player.Functions then
        return false
    end

    player.Functions.AddMoney(account, amount, 'am-bridge')
    return true
end

function Adapter.RemoveMoney(source, account, amount)
    local player = Adapter.GetPlayer(source)
    if not player or not player.Functions then
        return false
    end

    return player.Functions.RemoveMoney(account, amount, 'am-bridge') == true
end

AMBridge.RegisterFramework('qb', Adapter)
