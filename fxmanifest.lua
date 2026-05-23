fx_version 'cerulean'
game 'gta5'

author 'AM-Scripts / AidenMouse'
description 'AM-Bridge - clean framework, inventory, and notification bridge for FiveM resources.'
version '1.0.0'

lua54 'yes'

shared_scripts {
    'config.lua',
    'shared/main.lua',
    'shared/adapters/unc.lua',
    'shared/adapters/qbox.lua',
    'shared/adapters/qb.lua',
    'shared/adapters/standalone.lua',
    'shared/adapters/custom_example.lua',
    'shared/inventory/unc.lua',
    'shared/inventory/ox.lua',
    'shared/inventory/qb.lua',
    'shared/inventory/standalone.lua',
    'shared/notifications/unc.lua',
    'shared/notifications/ox.lua',
    'shared/notifications/qb.lua',
    'shared/notifications/standalone.lua'
}

server_scripts {
    'server/main.lua',
    'examples/example.lua'
}

client_scripts {
    'client/main.lua'
}

server_exports {
    'GetFramework',
    'GetPlayer',
    'GetIdentifier',
    'GetName',
    'GetJob',
    'GetMoney',
    'AddMoney',
    'RemoveMoney',
    'HasItem',
    'AddItem',
    'RemoveItem',
    'Notify',
    'RegisterCallback',
    'TriggerCallback'
}

client_exports {
    'GetFramework',
    'GetPlayer',
    'GetIdentifier',
    'GetName',
    'GetJob',
    'GetMoney',
    'AddMoney',
    'RemoveMoney',
    'HasItem',
    'AddItem',
    'RemoveItem',
    'Notify',
    'RegisterCallback',
    'TriggerCallback'
}

dependencies {
    '/server:5848'
}
