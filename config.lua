Config = Config or {}

Config.Debug = true

-- Framework detection order. The first active adapter wins.
-- Supported by default: qbx_core, qb-core, standalone.
Config.FrameworkPriority = {
    'unc',
    'qbox',
    'qb',
    'standalone'
}

-- Inventory detection order. The first active adapter wins.
-- Supported by default: ox_inventory, qb-inventory, standalone.
Config.InventoryPriority = {
    'ox',
    'qb',
    'unc',
    'standalone'
}

-- Notification detection order. The first active adapter wins.
-- Supported by default: ox_lib, QBCore notify, standalone chat.
Config.NotificationPriority = {
    'unc',
    'ox',
    'qb',
    'standalone'
}

Config.DefaultMoneyAccount = 'cash'
Config.DefaultNotifyType = 'inform'
Config.DefaultNotifyDuration = 5000

-- Set this to true only if you intentionally want the example file to print
-- usage guidance on resource start.
Config.EnableExampleUsagePrint = false
