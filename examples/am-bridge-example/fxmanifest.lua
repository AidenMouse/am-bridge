fx_version 'cerulean'
game 'gta5'

author 'AM-Scripts / AidenMouse'
description 'Example resource showing how to use AM-Bridge exports.'
version '1.0.0'

lua54 'yes'

shared_script 'config.lua'

server_script 'server/main.lua'
client_script 'client/main.lua'

dependencies {
    'am-bridge'
}
