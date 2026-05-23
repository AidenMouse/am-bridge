local Adapter = {
    name = 'standalone',
    label = 'Standalone Inventory'
}

function Adapter.IsActive()
    return true
end

function Adapter.HasItem()
    return false
end

function Adapter.AddItem()
    return false
end

function Adapter.RemoveItem()
    return false
end

AMBridge.RegisterInventory('standalone', Adapter)
