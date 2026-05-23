local Adapter = {
    name = 'unc',
    label = 'unc_core'
}

local UNC = nil

local function getCore()
    if UNC then
        return UNC
    end

    if GetResourceState('unc_core') ~= 'started' then
        return nil
    end

    local ok, core = pcall(function()
        return exports['unc_core']:GetCoreObject()
    end)

    if ok and core then
        UNC = core
    end

    return UNC
end

function Adapter.IsActive(isResourceStarted)
    return isResourceStarted('unc_core')
end

function Adapter.GetPlayer(source)
    local core = getCore()
    if not core or not core.Functions then
        return nil
    end

    if IsDuplicityVersion() and core.Functions.GetPlayer then
        return core.Functions.GetPlayer(source)
    end

    if not IsDuplicityVersion() and core.Functions.GetPlayerData then
        return {
            PlayerData = core.Functions.GetPlayerData()
        }
    end

    return nil
end

function Adapter.GetIdentifier(source)
    local player = Adapter.GetPlayer(source)
    local data = player and player.PlayerData or {}

    return data.citizenid or data.license or nil
end

function Adapter.GetName(source)
    local player = Adapter.GetPlayer(source)
    local data = player and player.PlayerData or {}
    local charinfo = data.charinfo or {}
    local firstName = charinfo.firstname or ''
    local lastName = charinfo.lastname or ''
    local fullName = (firstName .. ' ' .. lastName):gsub('^%s*(.-)%s*$', '%1')

    return fullName ~= '' and fullName or data.name or GetPlayerName(source) or 'Unknown'
end

function Adapter.GetJob(source)
    local player = Adapter.GetPlayer(source)
    local job = player and player.PlayerData and player.PlayerData.job or {}
    local gradeValue = job.grade

    if type(gradeValue) == 'table' then
        gradeValue = gradeValue.level or gradeValue.grade or 0
    end

    return {
        name = job.name or 'unemployed',
        label = job.label or job.name or 'Unemployed',
        grade = tonumber(gradeValue) or 0,
        gradeLabel = job.grade_label or job.gradeLabel or 'None',
        onDuty = job.onduty ~= false
    }
end

function Adapter.GetMoney(source, account)
    local player = Adapter.GetPlayer(source)
    local money = player and player.PlayerData and player.PlayerData.money or {}

    return tonumber(money[account]) or 0
end

function Adapter.AddMoney(source, account, amount)
    local player = Adapter.GetPlayer(source)
    if not player or not player.Functions or not player.Functions.AddMoney then
        return false
    end

    return player.Functions.AddMoney(account, amount, 'am-bridge') == true
end

function Adapter.RemoveMoney(source, account, amount)
    local player = Adapter.GetPlayer(source)
    if not player or not player.Functions or not player.Functions.RemoveMoney then
        return false
    end

    return player.Functions.RemoveMoney(account, amount, 'am-bridge') == true
end

AMBridge.RegisterFramework('unc', Adapter)
