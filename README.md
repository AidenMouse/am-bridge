# AM-Bridge

A clean, modular framework bridge for FiveM resources.

AM-Bridge helps developers write one script that can support multiple server setups without rewriting the core logic for every framework, inventory, or notification system.

It is built to be simple, readable, and easy to extend.

## Features

- Auto-detects the active framework
- Supports unc_core by default
- Supports Qbox by default
- Supports QBCore by default
- Includes standalone fallback support
- Modular framework adapter system
- Modular inventory adapter system
- Modular notification adapter system
- Easy custom framework support
- Server and client exports
- Built-in callback wrapper
- Debug command for quick checks
- Clean beginner-friendly code
- No escrow
- No paid lock system

## Compatibility

### Frameworks

| Framework | Resource | Status |
| --- | --- | --- |
| UNC Core | `unc_core` | Supported |
| Qbox | `qbx_core` | Supported |
| QBCore | `qb-core` | Supported |
| Standalone | None required | Supported |

Frameworks outside this list are not included by default. You can add your own with a custom adapter.

### Inventories

| Inventory | Resource | Status |
| --- | --- | --- |
| ox_inventory | `ox_inventory` | Supported |
| qb-inventory | `qb-inventory` | Supported |
| UNC Core Inventory | `unc_core` | Supported fallback |
| Standalone | None required | Supported fallback |

### Notifications

| Notification System | Resource | Status |
| --- | --- | --- |
| UNC Core Notify | `unc_core` | Supported |
| ox_lib notify | `ox_lib` | Supported |
| QBCore notify | `qb-core` | Supported |
| Chat fallback | `chat` | Supported fallback |

## unc_core Support

`unc_core` is supported as a first-class framework adapter.

When `unc_core` is running, AM-Bridge can use it for:

- Player objects
- Character identifiers
- Character names
- Jobs
- Cash and bank money
- Add/remove money
- Basic internal inventory fallback
- Notifications

Recommended start order:

```cfg
ensure ox_lib
ensure oxmysql
ensure unc_core
ensure am-bridge
```

If you use `ox_inventory` with `unc_core`, start `ox_inventory` before `am-bridge`. AM-Bridge will prefer `ox_inventory` for inventory operations and use `unc_core` for framework/player data.

```cfg
ensure ox_lib
ensure oxmysql
ensure unc_core
ensure ox_inventory
ensure am-bridge
```

The export usage stays the same:

```lua
local identifier = exports['am-bridge']:GetIdentifier(source)
local job = exports['am-bridge']:GetJob(source)
local cash = exports['am-bridge']:GetMoney(source, 'cash')

exports['am-bridge']:AddMoney(source, 'cash', 500)
exports['am-bridge']:Notify(source, 'Welcome to UNC Core.', 'success', 5000)
```

## ox_lib Support

`ox_lib` is supported as an optional notification provider.

AM-Bridge does not require `ox_lib` to run. If `ox_lib` is started before `am-bridge`, AM-Bridge will automatically use `ox_lib` notifications. If `ox_lib` is not running, it will fall back to QBCore notify or chat depending on what is available.

Recommended start order when using `ox_lib`:

```cfg
ensure ox_lib
ensure am-bridge
```

With Qbox and ox_inventory:

```cfg
ensure qbx_core
ensure ox_lib
ensure ox_inventory
ensure am-bridge
```

Notification usage stays the same no matter which notification system is active:

```lua
exports['am-bridge']:Notify(source, 'Saved successfully.', 'success', 5000)
```

## Resource Structure

```text
am-bridge/
  fxmanifest.lua
  config.lua
  README.md
  shared/
    main.lua
    adapters/
      unc.lua
      qb.lua
      qbox.lua
      standalone.lua
      custom_example.lua
    inventory/
      unc.lua
      ox.lua
      qb.lua
      standalone.lua
    notifications/
      unc.lua
      ox.lua
      qb.lua
      standalone.lua
  server/
    main.lua
  client/
    main.lua
  examples/
    example.lua
```

## Installation

1. Download or clone this resource.
2. Place the folder in your FiveM resources directory.
3. Make sure the folder is named:

```text
am-bridge
```

4. Add it to your `server.cfg` after your framework and inventory resources, but before scripts that use AM-Bridge.

### Qbox Example

```cfg
ensure qbx_core
ensure ox_lib
ensure ox_inventory
ensure am-bridge
```

### UNC Core Example

```cfg
ensure ox_lib
ensure oxmysql
ensure unc_core
ensure am-bridge
```

### QBCore Example

```cfg
ensure qb-core
ensure qb-inventory
ensure am-bridge
```

### Standalone Example

```cfg
ensure am-bridge
```

## Configuration

All main settings are inside `config.lua`.

### Debug

```lua
Config.Debug = true
```

### Framework Priority

AM-Bridge checks frameworks in this order. The first active adapter wins.

```lua
Config.FrameworkPriority = {
    'unc',
    'qbox',
    'qb',
    'standalone'
}
```

### Inventory Priority

```lua
Config.InventoryPriority = {
    'ox',
    'qb',
    'unc',
    'standalone'
}
```

### Notification Priority

```lua
Config.NotificationPriority = {
    'unc',
    'ox',
    'qb',
    'standalone'
}
```

### Defaults

```lua
Config.DefaultMoneyAccount = 'cash'
Config.DefaultNotifyType = 'inform'
Config.DefaultNotifyDuration = 5000
```

## Debug Command

Use the debug command to check what AM-Bridge detected.

```text
/ambridge
```

It shows:

- Detected framework
- Detected inventory
- Detected notification system

This command can be used in-game or from the server console.

## Exports

AM-Bridge provides exports with the same names on server and client where possible.

Most player data, money, and inventory operations should be called server-side for security and reliability.

## Making Your Script Use AM-Bridge

If you want your own resource to work across `unc_core`, Qbox, QBCore, and standalone setups, build it against AM-Bridge instead of calling a framework directly.

You can also freely use AI tools to help convert your script to AM-Bridge. Paste your script code into your preferred AI assistant and ask it to replace direct framework, inventory, and notification calls with AM-Bridge exports.

Example AI prompt:

```text
Convert this FiveM script to use AM-Bridge.

Rules:
- Do not use direct QBCore, Qbox, unc_core, ox_inventory, qb-inventory, or notification calls unless absolutely required.
- Use exports['am-bridge'] for player data, identifiers, jobs, money, inventory, notifications, and callbacks.
- Keep all money and inventory changes server-side.
- Do not add ESX support.
- Keep the code clean and beginner-friendly.
```

### 1. Add AM-Bridge as a Dependency

In your script's `fxmanifest.lua`, add:

```lua
dependencies {
    'am-bridge'
}
```

Or, if you already have dependencies:

```lua
dependencies {
    'ox_lib',
    'am-bridge'
}
```

Then make sure your `server.cfg` starts AM-Bridge before your script:

```cfg
ensure am-bridge
ensure my-script
```

### 2. Use AM-Bridge Exports in Server Files

Example `server/main.lua`:

```lua
RegisterNetEvent('my-script:server:rewardPlayer', function()
    local source = source
    local identifier = exports['am-bridge']:GetIdentifier(source)

    if not identifier then
        print('[my-script] Could not find player identifier.')
        return
    end

    exports['am-bridge']:AddMoney(source, 'cash', 500)
    exports['am-bridge']:Notify(source, 'You received $500.', 'success', 5000)
end)
```

### 3. Use AM-Bridge Exports in Client Files

Example `client/main.lua`:

```lua
RegisterCommand('myframework', function()
    local framework = exports['am-bridge']:GetFramework()
    exports['am-bridge']:Notify(('Detected framework: %s'):format(framework), 'inform', 5000)
end, false)
```

### 4. Replace Direct Framework Calls

Instead of doing this:

```lua
local QBCore = exports['qb-core']:GetCoreObject()
local Player = QBCore.Functions.GetPlayer(source)
local identifier = Player.PlayerData.citizenid
```

Do this:

```lua
local identifier = exports['am-bridge']:GetIdentifier(source)
```

Instead of doing this:

```lua
TriggerClientEvent('QBCore:Notify', source, 'Done!', 'success')
```

Do this:

```lua
exports['am-bridge']:Notify(source, 'Done!', 'success', 5000)
```

Instead of doing this:

```lua
local Player = QBCore.Functions.GetPlayer(source)
Player.Functions.AddMoney('cash', 500)
```

Do this:

```lua
exports['am-bridge']:AddMoney(source, 'cash', 500)
```

### 5. Recommended Pattern

Keep all framework-related logic going through AM-Bridge:

```lua
RegisterNetEvent('my-script:server:useItem', function()
    local source = source

    if not exports['am-bridge']:HasItem(source, 'lockpick', 1) then
        exports['am-bridge']:Notify(source, 'You need a lockpick.', 'error', 5000)
        return
    end

    exports['am-bridge']:RemoveItem(source, 'lockpick', 1)
    exports['am-bridge']:Notify(source, 'Lockpick used.', 'success', 5000)
end)
```

This means your script does not need to know if the server is using `unc_core`, Qbox, QBCore, `ox_inventory`, or `qb-inventory`.

### Export List

| Export | Purpose |
| --- | --- |
| `GetFramework()` | Returns the detected framework name |
| `GetPlayer(source)` | Returns the framework player object or standalone player table |
| `GetIdentifier(source)` | Returns the player's main identifier |
| `GetName(source)` | Returns the player's character name or FiveM name |
| `GetJob(source)` | Returns normalized job data |
| `GetMoney(source, account)` | Gets player money |
| `AddMoney(source, account, amount)` | Adds money to a player |
| `RemoveMoney(source, account, amount)` | Removes money from a player |
| `HasItem(source, item, amount)` | Checks if a player has an item |
| `AddItem(source, item, amount, metadata)` | Adds an item to a player |
| `RemoveItem(source, item, amount)` | Removes an item from a player |
| `Notify(source, message, type, duration)` | Sends a notification |
| `RegisterCallback(name, cb)` | Registers a bridge callback |
| `TriggerCallback(...)` | Triggers a bridge callback |

## Server Usage

### Get Detected Framework

```lua
local framework = exports['am-bridge']:GetFramework()
print(('Framework: %s'):format(framework))
```

### Get Player Identifier

```lua
local identifier = exports['am-bridge']:GetIdentifier(source)

if not identifier then
    print('Could not find player identifier.')
    return
end

print(('Player identifier: %s'):format(identifier))
```

### Get Player Name

```lua
local name = exports['am-bridge']:GetName(source)
print(('Player name: %s'):format(name))
```

### Get Player Job

```lua
local job = exports['am-bridge']:GetJob(source)

print(('Job: %s'):format(job.name))
print(('Grade: %s'):format(job.grade))
```

Normalized job response:

```lua
{
    name = 'police',
    label = 'Police',
    grade = 2,
    gradeLabel = 'Sergeant',
    onDuty = true
}
```

### Get Money

```lua
local cash = exports['am-bridge']:GetMoney(source, 'cash')
local bank = exports['am-bridge']:GetMoney(source, 'bank')

print(('Cash: %s | Bank: %s'):format(cash, bank))
```

### Add Money

```lua
local success = exports['am-bridge']:AddMoney(source, 'cash', 500)

if success then
    exports['am-bridge']:Notify(source, 'You received $500.', 'success', 5000)
end
```

### Remove Money

```lua
local success = exports['am-bridge']:RemoveMoney(source, 'cash', 250)

if not success then
    exports['am-bridge']:Notify(source, 'You do not have enough cash.', 'error', 5000)
end
```

### Check Item

```lua
local hasItem = exports['am-bridge']:HasItem(source, 'lockpick', 1)

if not hasItem then
    exports['am-bridge']:Notify(source, 'You need a lockpick.', 'error', 5000)
    return
end
```

### Add Item

```lua
exports['am-bridge']:AddItem(source, 'water', 2, {
    quality = 100
})
```

### Remove Item

```lua
local removed = exports['am-bridge']:RemoveItem(source, 'lockpick', 1)

if removed then
    exports['am-bridge']:Notify(source, 'Lockpick used.', 'inform', 5000)
end
```

### Send Notification

```lua
exports['am-bridge']:Notify(source, 'Action completed.', 'success', 5000)
```

Common notification types:

```text
inform
success
error
warning
```

## Client Usage

Client-side exports are available, but sensitive player data should still be requested from the server.

### Get Framework

```lua
local framework = exports['am-bridge']:GetFramework()
print(framework)
```

### Notify Locally

```lua
exports['am-bridge']:Notify('Hello from AM-Bridge.', 'inform', 5000)
```

### Client Item Check

Client item checks use the built-in callback wrapper.

```lua
exports['am-bridge']:HasItem('lockpick', 1, function(hasItem)
    if hasItem then
        print('Player has a lockpick.')
    else
        print('Player does not have a lockpick.')
    end
end)
```

## Callback System

AM-Bridge includes a simple callback wrapper so scripts can communicate between server and client without depending directly on a framework callback system.

### Server Callback

Register a server callback:

```lua
exports['am-bridge']:RegisterCallback('my-resource:getPlayerData', function(source, cb)
    local data = {
        identifier = exports['am-bridge']:GetIdentifier(source),
        name = exports['am-bridge']:GetName(source),
        job = exports['am-bridge']:GetJob(source)
    }

    cb(data)
end)
```

Trigger it from the client:

```lua
exports['am-bridge']:TriggerCallback('my-resource:getPlayerData', function(data)
    print(data.identifier)
    print(data.name)
    print(data.job.name)
end)
```

### Client Callback

Register a client callback:

```lua
exports['am-bridge']:RegisterCallback('my-resource:getCoords', function(cb)
    local coords = GetEntityCoords(PlayerPedId())
    cb(coords)
end)
```

Trigger it from the server:

```lua
exports['am-bridge']:TriggerCallback(source, 'my-resource:getCoords', function(coords)
    print(coords)
end)
```

## Example Resource Usage

This is an example server-side event using AM-Bridge.

```lua
RegisterNetEvent('my-resource:server:buyWater', function()
    local source = source
    local price = 50

    local cash = exports['am-bridge']:GetMoney(source, 'cash')

    if cash < price then
        exports['am-bridge']:Notify(source, 'You need $50 cash.', 'error', 5000)
        return
    end

    local paid = exports['am-bridge']:RemoveMoney(source, 'cash', price)
    if not paid then
        exports['am-bridge']:Notify(source, 'Payment failed.', 'error', 5000)
        return
    end

    local added = exports['am-bridge']:AddItem(source, 'water', 1)
    if not added then
        exports['am-bridge']:AddMoney(source, 'cash', price)
        exports['am-bridge']:Notify(source, 'Inventory is full. Refunded.', 'error', 5000)
        return
    end

    exports['am-bridge']:Notify(source, 'You bought water.', 'success', 5000)
end)
```

## Adapter System

Adapters are small files that translate AM-Bridge exports into framework-specific code.

Framework adapters live here:

```text
shared/adapters/
```

Inventory adapters live here:

```text
shared/inventory/
```

Notification adapters live here:

```text
shared/notifications/
```

Each adapter registers itself with AM-Bridge.

Framework example:

```lua
AMBridge.RegisterFramework('qb', Adapter)
```

Inventory example:

```lua
AMBridge.RegisterInventory('ox', Adapter)
```

Notification example:

```lua
AMBridge.RegisterNotification('ox', Adapter)
```

## Adding a Custom Framework

AM-Bridge includes a custom framework example:

```text
shared/adapters/custom_example.lua
```

To add your own framework:

1. Copy `shared/adapters/custom_example.lua`.
2. Rename it, for example `shared/adapters/myframework.lua`.
3. Add the new file to `fxmanifest.lua` under `shared_scripts`.
4. Change the adapter name and label.
5. Make `Adapter.IsActive()` return true when your framework is running.
6. Fill in the adapter functions using your framework API.
7. Add your adapter name to `Config.FrameworkPriority`.

### Custom Framework Template

```lua
local Adapter = {
    name = 'myframework',
    label = 'My Framework'
}

function Adapter.IsActive(isResourceStarted)
    return isResourceStarted('my_framework')
end

function Adapter.GetPlayer(source)
    return exports['my_framework']:GetPlayer(source)
end

function Adapter.GetIdentifier(source)
    local player = Adapter.GetPlayer(source)
    return player and player.identifier or nil
end

function Adapter.GetName(source)
    local player = Adapter.GetPlayer(source)
    return player and player.name or GetPlayerName(source) or 'Unknown'
end

function Adapter.GetJob(source)
    local player = Adapter.GetPlayer(source)
    local job = player and player.job or {}

    return {
        name = job.name or 'unemployed',
        label = job.label or job.name or 'Unemployed',
        grade = job.grade or 0,
        gradeLabel = job.gradeLabel or 'None',
        onDuty = job.onDuty or false
    }
end

function Adapter.GetMoney(source, account)
    return exports['my_framework']:GetMoney(source, account) or 0
end

function Adapter.AddMoney(source, account, amount)
    return exports['my_framework']:AddMoney(source, account, amount) == true
end

function Adapter.RemoveMoney(source, account, amount)
    return exports['my_framework']:RemoveMoney(source, account, amount) == true
end

AMBridge.RegisterFramework('myframework', Adapter)
```

Then update `config.lua`:

```lua
Config.FrameworkPriority = {
    'myframework',
    'qbox',
    'qb',
    'standalone'
}
```

Your other scripts do not need to change. They can keep using AM-Bridge exports.

## Adding a Custom Inventory

Create a new file:

```text
shared/inventory/myinventory.lua
```

Register it like this:

```lua
local Adapter = {
    name = 'myinventory',
    label = 'My Inventory'
}

function Adapter.IsActive(isResourceStarted)
    return isResourceStarted('my_inventory')
end

function Adapter.HasItem(source, item, amount)
    return exports['my_inventory']:HasItem(source, item, amount or 1) == true
end

function Adapter.AddItem(source, item, amount, metadata)
    return exports['my_inventory']:AddItem(source, item, amount or 1, metadata) == true
end

function Adapter.RemoveItem(source, item, amount)
    return exports['my_inventory']:RemoveItem(source, item, amount or 1) == true
end

AMBridge.RegisterInventory('myinventory', Adapter)
```

Add the file to `fxmanifest.lua`, then update `Config.InventoryPriority`.

## Adding a Custom Notification System

Create a new file:

```text
shared/notifications/mynotify.lua
```

Register it like this:

```lua
local Adapter = {
    name = 'mynotify',
    label = 'My Notify'
}

function Adapter.IsActive(isResourceStarted)
    return isResourceStarted('my_notify')
end

function Adapter.Notify(source, message, notifyType, duration)
    if IsDuplicityVersion() then
        TriggerClientEvent('my_notify:client:send', source, message, notifyType, duration)
    else
        exports['my_notify']:Send(message, notifyType, duration)
    end

    return true
end

AMBridge.RegisterNotification('mynotify', Adapter)
```

Add the file to `fxmanifest.lua`, then update `Config.NotificationPriority`.

## Return Values

### `GetFramework()`

Returns:

```lua
'unc'
'qbox'
'qb'
'standalone'
```

### `GetJob(source)`

Always returns a table:

```lua
{
    name = 'unemployed',
    label = 'Unemployed',
    grade = 0,
    gradeLabel = 'None',
    onDuty = false
}
```

### Money Functions

`GetMoney` returns a number.

`AddMoney` and `RemoveMoney` return `true` or `false`.

### Inventory Functions

`HasItem`, `AddItem`, and `RemoveItem` return `true` or `false`.

Standalone inventory fallback returns `false` because there is no real inventory system to modify.

## Best Practices

- Call money and inventory exports from the server.
- Start AM-Bridge before any resource that uses it.
- Keep custom adapter names short and lowercase.
- Use the debug command after changing framework or inventory resources.
- Do not edit every script for each framework. Add or update an adapter instead.
- Keep framework-specific logic inside adapter files only.

## Troubleshooting

### AM-Bridge detects standalone

Check your start order. Your framework should start before AM-Bridge.

Example:

```cfg
ensure qbx_core
ensure am-bridge
```

or:

```cfg
ensure qb-core
ensure am-bridge
```

Then run:

```text
/ambridge
```

### Inventory functions return false

Check that your inventory resource is started before AM-Bridge.

For ox_inventory:

```cfg
ensure ox_inventory
ensure am-bridge
```

For qb-inventory:

```cfg
ensure qb-inventory
ensure am-bridge
```

### Notifications go to chat

AM-Bridge falls back to chat if no supported notification system is detected.

Start `ox_lib` or `qb-core` before AM-Bridge if you want those notification systems.

### Client export says server-side only

Some data should not be trusted from the client. Use a server export or the callback system for identifiers, jobs, money, and inventory changes.

## Notes

- This resource does not use escrow.
- This resource does not include a paid licensing system.
- This resource is intended to be edited and extended.
- Framework-specific code should stay inside adapter files.

## Credits

Created by:

```text
AM-Scripts / AidenMouse
```

## License

Copyright (c) AM-Scripts / AidenMouse.

This resource is provided as source code for use in FiveM servers. If you plan to redistribute modified versions, include clear credit to AM-Scripts / AidenMouse.
