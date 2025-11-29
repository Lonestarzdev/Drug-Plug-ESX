--shared_script "@ReaperV4/imports/bypass.lua"
--shared_script "@ReaperV4/imports/bypass_s.lua"
--shared_script "@ReaperV4/imports/bypass_c.lua"
--lua54 "yes" -- needed for Reaper

fx_version 'cerulean'
game 'gta5'

author 'savagedev'
description 'ESX Drug Plug Script'
version '1.0.0'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
    'config.lua'
}
