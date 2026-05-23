local Adapter = {
    name = 'ox',
    label = 'ox_inventory'
}

function Adapter.IsActive(isResourceStarted)
    return isResourceStarted('ox_inventory')
end

function Adapter.HasItem(source, item, amount)
    if not item then
        return false
    end

    local count = exports.ox_inventory:Search(source, 'count', item) or 0
    return count >= (amount or 1)
end

function Adapter.AddItem(source, item, amount, metadata)
    if not item then
        return false
    end

    return exports.ox_inventory:AddItem(source, item, amount or 1, metadata) == true
end

function Adapter.RemoveItem(source, item, amount)
    if not item then
        return false
    end

    return exports.ox_inventory:RemoveItem(source, item, amount or 1) == true
end

AMBridge.RegisterInventory('ox', Adapter)
