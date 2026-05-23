# AM-Bridge Example Resource

This is a complete example resource showing how another FiveM script can depend
on AM-Bridge.

## Install

Copy `am-bridge-example` into your resources folder next to `am-bridge`.

Start it after AM-Bridge:

```cfg
ensure am-bridge
ensure am-bridge-example
```

## Commands

```text
/ambridge_client_test
/ambridge_server_test
```

The example:

- Gets the detected framework
- Gets the player identifier
- Gets the player name
- Gets the player job
- Checks for a configured item
- Removes that item
- Gives money
- Sends notifications

Adjust `config.lua` to change the required item or reward.
